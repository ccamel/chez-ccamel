#!/usr/bin/env python3
"""Update managed binary resources from their latest GitHub release."""

from __future__ import annotations

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
MARKER = "# managed by update-package"
SYSTEMS = ("x86_64-linux", "aarch64-darwin")


class UpdateError(Exception):
    """An expected failure while collecting or applying resource metadata."""


@dataclass(frozen=True)
class Resource:
    repository: str
    file: Path
    assets: tuple[tuple[str, str], ...]


RESOURCES = MappingProxyType(
    {
        "omp": Resource(
            repository="can1357/oh-my-pi",
            file=Path("nix-config/packages/omp.nix"),
            assets=(
                ("x86_64-linux", "omp-linux-x64"),
                ("aarch64-darwin", "omp-darwin-arm64"),
            ),
        ),
        "herdr": Resource(
            repository="ogulcancelik/herdr",
            file=Path("nix-config/packages/herdr.nix"),
            assets=(
                ("x86_64-linux", "herdr-linux-x86_64"),
                ("aarch64-darwin", "herdr-macos-aarch64"),
            ),
        ),
    }
)


def latest_release_tag(repository: str) -> str:
    request = Request(
        f"https://api.github.com/repos/{repository}/releases/latest",
        headers={"User-Agent": "chez-ccamel-update-resource"},
    )

    try:
        with urlopen(request) as response:  # noqa: S310: GitHub API URL is constructed above.
            payload = json.load(response)
    except (HTTPError, URLError, OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"could not fetch the latest release for {repository}: {error}") from error

    tag = payload.get("tag_name") if isinstance(payload, dict) else None
    if not isinstance(tag, str) or not tag.startswith("v") or len(tag) == 1:
        raise UpdateError(f"latest release for {repository} has an invalid tag: {tag!r}")

    return tag


def prefetch_hash(url: str) -> str:
    try:
        result = subprocess.run(
            ["nix", "store", "prefetch-file", "--json", url],
            check=True,
            capture_output=True,
            text=True,
        )
        payload = json.loads(result.stdout)
    except subprocess.CalledProcessError as error:
        raise UpdateError(
            f"could not prefetch {url}: {error.stderr.strip() or error}"
        ) from error
    except json.JSONDecodeError as error:
        raise UpdateError(f"nix returned invalid JSON while prefetching {url}: {error}") from error

    resource_hash = payload.get("hash") if isinstance(payload, dict) else None
    if not isinstance(resource_hash, str) or not resource_hash:
        raise UpdateError(f"nix did not return a hash while prefetching {url}")

    return resource_hash


def replacement_line(line: str, name: str, value: str) -> str | None:
    stripped = line.strip()
    prefix = f'{name} = "'
    suffix = '";'
    if not stripped.startswith(prefix) or not stripped.endswith(suffix):
        return None

    indentation = line[: len(line) - len(line.lstrip())]
    newline = "\n" if line.endswith("\n") else ""
    return f'{indentation}{name} = "{value}";{newline}'


def update_marked_values(contents: str, version: str, hashes: tuple[str, str]) -> str:
    lines = contents.splitlines(keepends=True)
    markers = [index for index, line in enumerate(lines) if line.strip() == MARKER]
    if len(markers) != 3:
        raise UpdateError(f"expected exactly three {MARKER!r} markers, found {len(markers)}")

    version_marker, *hash_markers = markers
    if version_marker + 1 >= len(lines):
        raise UpdateError("version marker is not followed by an assignment")

    replacement = replacement_line(lines[version_marker + 1], "version", version)
    if replacement is None:
        raise UpdateError('version marker must be followed by version = "...";')
    lines[version_marker + 1] = replacement

    if len(hash_markers) != 2:
        raise UpdateError("expected exactly two hash markers")
    for marker, resource_hash in zip(hash_markers, hashes, strict=True):
        if marker + 1 >= len(lines):
            raise UpdateError("hash marker is not followed by an assignment")
        replacement = replacement_line(lines[marker + 1], "hash", resource_hash)
        if replacement is None:
            raise UpdateError('hash marker must be followed by hash = "...";')
        lines[marker + 1] = replacement

    return "".join(lines)


def run_post_update_checks(resource: Resource) -> int:
    expression = (
        "let "
        "flake = builtins.getFlake (toString ./nix-config); "
        "pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; "
        f"in pkgs.callPackage ./{resource.file.as_posix()} {{ }}"
    )
    commands = (
        ("formatting", ["just", "fmt"]),
        (
            "targeted Nix build",
            ["nix", "build", "--no-link", "--impure", "--expr", expression],
        ),
    )
    failed = False

    try:
        for description, command in commands:
            print(f"Running {description}...", flush=True)
            try:
                subprocess.run(command, check=True, cwd=ROOT)
            except subprocess.CalledProcessError as error:
                failed = True
                print(f"{description} failed: {error}", file=sys.stderr)
    finally:
        subprocess.run(
            ["git", "--no-pager", "diff", "--", resource.file.as_posix()],
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

    try:
        tag = latest_release_tag(resource.repository)
        version = tag.removeprefix("v")
        urls = tuple(
            (
                system,
                f"https://github.com/{resource.repository}/releases/download/{tag}/{asset}",
            )
            for system, asset in resource.assets
        )
        hashes = tuple(prefetch_hash(url) for _, url in urls)
        if tuple(system for system, _ in urls) != SYSTEMS:
            raise UpdateError(f"{args.resource} has unsupported asset system ordering")

        package_file = ROOT / resource.file
        updated = update_marked_values(package_file.read_text(), version, hashes)
    except (OSError, UpdateError) as error:
        print(f"update-resource: {error}", file=sys.stderr)
        return 1

    print(f"Tag: {tag}", flush=True)
    for (system, url), resource_hash in zip(urls, hashes, strict=True):
        print(f"{system} URL: {url}", flush=True)
        print(f"{system} hash: {resource_hash}", flush=True)

    package_file.write_text(updated)
    return run_post_update_checks(resource)


if __name__ == "__main__":
    raise SystemExit(main())
