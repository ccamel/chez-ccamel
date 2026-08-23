#!/usr/bin/env python3
"""Update managed resources from their upstream source."""

from __future__ import annotations

from collections.abc import Mapping
import argparse
import json
import subprocess
import sys
from dataclasses import dataclass
from pathlib import Path
from types import MappingProxyType
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
MARKER = "# managed by update-resource"
SYSTEMS = ("x86_64-linux", "aarch64-darwin")


class UpdateError(Exception):
    """An expected failure while collecting or applying resource metadata."""


@dataclass(frozen=True)
class GitHubReleaseResource:
    repository: str
    file: Path
    assets: tuple[tuple[str, str], ...]


@dataclass(frozen=True)
class FetchUrlResource:
    url: str
    file: Path


Resource = GitHubReleaseResource | FetchUrlResource


@dataclass(frozen=True)
class ResourceUpdate:
    values: tuple[tuple[str, str], ...]
    output: tuple[str, ...]


RESOURCES: Mapping[str, Resource] = MappingProxyType(
    {
        "omp": GitHubReleaseResource(
            repository="can1357/oh-my-pi",
            file=Path("nix-config/packages/omp.nix"),
            assets=(
                ("x86_64-linux", "omp-linux-x64"),
                ("aarch64-darwin", "omp-darwin-arm64"),
            ),
        ),
        "herdr": GitHubReleaseResource(
            repository="ogulcancelik/herdr",
            file=Path("nix-config/packages/herdr.nix"),
            assets=(
                ("x86_64-linux", "herdr-linux-x86_64"),
                ("aarch64-darwin", "herdr-macos-aarch64"),
            ),
        ),
        "herd": FetchUrlResource(
            url="https://gist.githubusercontent.com/ccamel/46a021372c326f31fdb3b5a55b238214/raw/herd",
            file=Path("nix-config/packages/herd.nix"),
        ),
    }
)


def latest_release_tag(repository: str) -> str:
    request = Request(
        f"https://api.github.com/repos/{repository}/releases/latest",
        headers={"User-Agent": "chez-ccamel-update-resource"},
    )
    print(f"Fetching latest release for {repository}...", flush=True)


    try:
        with urlopen(request) as response:  # noqa: S310  # GitHub API URL is constructed above.
            payload = json.load(response)
    except (HTTPError, URLError, OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"could not fetch the latest release for {repository}: {error}") from error

    tag = payload.get("tag_name") if isinstance(payload, dict) else None
    if not isinstance(tag, str) or not tag.startswith("v") or len(tag) == 1:
        raise UpdateError(f"latest release for {repository} has an invalid tag: {tag!r}")

    return tag


def prefetch_hash(url: str) -> str:
    print(f"Prefetching {url}...", flush=True)
    try:
        result = subprocess.run(
            ["nix", "store", "prefetch-file", "--json", url],
            check=True,
            stdout=subprocess.PIPE,
            stderr=sys.stdout,
            text=True,
        )
        payload = json.loads(result.stdout)
    except subprocess.CalledProcessError as error:
        raise UpdateError(f"could not prefetch {url}: {error}") from error
    except json.JSONDecodeError as error:
        raise UpdateError(f"nix returned invalid JSON while prefetching {url}: {error}") from error

    resource_hash = payload.get("hash") if isinstance(payload, dict) else None
    if not isinstance(resource_hash, str) or not resource_hash:
        raise UpdateError(f"nix did not return a hash while prefetching {url}")

    return resource_hash


def release_update(resource: GitHubReleaseResource) -> ResourceUpdate:
    tag = latest_release_tag(resource.repository)
    urls = tuple(
        (
            system,
            f"https://github.com/{resource.repository}/releases/download/{tag}/{asset}",
        )
        for system, asset in resource.assets
    )
    if tuple(system for system, _ in urls) != SYSTEMS:
        raise UpdateError(f"{resource.repository} has unsupported asset system ordering")

    hashes = tuple(prefetch_hash(url) for _, url in urls)
    return ResourceUpdate(
        values=(("version", tag.removeprefix("v")), *(("hash", resource_hash) for resource_hash in hashes)),
        output=(
            f"Tag: {tag}",
            *(f"{system} URL: {url}\n{system} hash: {resource_hash}" for (system, url), resource_hash in zip(urls, hashes, strict=True)),
        ),
    )


def fetchurl_update(resource: FetchUrlResource) -> ResourceUpdate:
    resource_hash = prefetch_hash(resource.url)
    return ResourceUpdate(
        values=(("hash", resource_hash),),
        output=(f"URL: {resource.url}", f"Hash: {resource_hash}"),
    )


def collect_update(resource: Resource) -> ResourceUpdate:
    if isinstance(resource, GitHubReleaseResource):
        return release_update(resource)
    return fetchurl_update(resource)


def replacement_line(line: str, name: str, value: str) -> str | None:
    stripped = line.strip()
    prefix = f'{name} = "'
    suffix = '";'
    if not stripped.startswith(prefix) or not stripped.endswith(suffix):
        return None

    indentation = line[: len(line) - len(line.lstrip())]
    newline = "\n" if line.endswith("\n") else ""
    return f'{indentation}{name} = "{value}";{newline}'


def update_marked_values(contents: str, values: tuple[tuple[str, str], ...]) -> str:
    lines = contents.splitlines(keepends=True)
    markers = [index for index, line in enumerate(lines) if line.strip() == MARKER]
    if len(markers) != len(values):
        raise UpdateError(f"expected exactly {len(values)} {MARKER!r} markers, found {len(markers)}")

    for marker, (name, value) in zip(markers, values, strict=True):
        if marker + 1 >= len(lines):
            raise UpdateError(f"{name} marker is not followed by an assignment")
        replacement = replacement_line(lines[marker + 1], name, value)
        if replacement is None:
            raise UpdateError(f'{name} marker must be followed by {name} = "...";')
        lines[marker + 1] = replacement

    return "".join(lines)


def build_expression(resource: Resource) -> str:
    return (
        "let "
        "flake = builtins.getFlake (toString ./nix-config); "
        "pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; "
        f"package = import ./{resource.file.as_posix()}; "
        "arguments = builtins.functionArgs package; "
        "in pkgs.callPackage package ("
        "(pkgs.lib.optionalAttrs (arguments ? omp) { "
        "omp = pkgs.callPackage ./nix-config/packages/omp.nix { }; "
        "}) // "
        "(pkgs.lib.optionalAttrs (arguments ? herdr) { "
        "herdr = pkgs.callPackage ./nix-config/packages/herdr.nix { }; "
        "})"
        ")"
    )


def run_post_update_checks(resource: Resource) -> int:
    commands = (
        ("formatting", ["just", "fmt"]),
        (
            "targeted Nix build",
            ["nix", "build", "--no-link", "--impure", "--expr", build_expression(resource)],
        ),
    )
    failed = False

    try:
        for description, command in commands:
            print(f"Running {description}...", flush=True)
            try:
                subprocess.run(command, check=True, cwd=ROOT, stdout=sys.stdout, stderr=sys.stderr)
            except subprocess.CalledProcessError as error:
                failed = True
                print(f"{description} failed: {error}", file=sys.stderr)
    finally:
        subprocess.run(
            ["git", "--no-pager", "diff", "--", resource.file.as_posix()],
            stdout=sys.stdout,
            stderr=sys.stderr,
            check=False,
            cwd=ROOT,
        )

    return 1 if failed else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("resource", choices=RESOURCES, help="resource to update")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    resource = RESOURCES[args.resource]
    print(f"Updating {args.resource}...", flush=True)


    try:
        update = collect_update(resource)
        package_file = ROOT / resource.file
        updated = update_marked_values(package_file.read_text(), update.values)
    except (OSError, UpdateError) as error:
        print(f"update-resource: {error}", file=sys.stderr)
        return 1

    for line in update.output:
        print(line, flush=True)

    print(f"Writing {package_file}...", flush=True)
    package_file.write_text(updated)
    return run_post_update_checks(resource)


if __name__ == "__main__":
    raise SystemExit(main())
