#!/usr/bin/env python3
"""Update managed resources from their upstream source."""

from __future__ import annotations

from collections.abc import Mapping
import argparse
from datetime import datetime
import json
import os
import re
import ssl
import subprocess
import sys
import tempfile
from dataclasses import dataclass
from pathlib import Path
from types import MappingProxyType
from urllib.error import HTTPError, URLError
from urllib.parse import quote
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parent.parent
MARKER = "# managed by update-resource"
SYSTEMS = ("x86_64-linux", "aarch64-darwin")

# Some Nix-managed corporate CA stores predate OpenSSL's strict extension checks;
# retain chain validation while accepting those explicitly trusted roots.
UPSTREAM_SSL_CONTEXT = ssl.create_default_context()
UPSTREAM_SSL_CONTEXT.verify_flags &= ~ssl.VERIFY_X509_STRICT


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


@dataclass(frozen=True)
class GitHubSourceResource:
    repository: str
    file: Path
    branch_manifest: str | None = None


@dataclass(frozen=True)
class NpmResource:
    package: str
    file: Path


@dataclass(frozen=True)
class QmdResource:
    file: Path


@dataclass(frozen=True)
class SkillsLintToolsResource:
    file: Path


Resource = GitHubReleaseResource | FetchUrlResource | GitHubSourceResource | NpmResource | QmdResource | SkillsLintToolsResource


@dataclass(frozen=True)
class ResourceUpdate:
    values: tuple[tuple[str, str], ...]
    output: tuple[str, ...]


RESOURCES: Mapping[str, Resource] = MappingProxyType(
    {
        "rtk": GitHubReleaseResource(
            repository="rtk-ai/rtk",
            file=Path("nix-config/packages/rtk.nix"),
            assets=(
                ("x86_64-linux", "rtk-x86_64-unknown-linux-musl.tar.gz"),
                ("aarch64-darwin", "rtk-aarch64-apple-darwin.tar.gz"),
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
        "livediff": GitHubReleaseResource(
            repository="SoCkEt7/Livediff",
            file=Path("nix-config/packages/livediff.nix"),
            assets=(
                ("x86_64-linux", "livediff-v{version}-x86_64-unknown-linux-musl.tar.gz"),
                ("aarch64-darwin", "livediff-v{version}-aarch64-apple-darwin.tar.gz"),
            ),
        ),
        "herdr-remote": GitHubSourceResource(
            repository="dcolinmorgan/herdr-remote",
            file=Path("nix-config/packages/herdr-remote.nix"),
        ),
        "herdr-annotate": GitHubSourceResource(
            repository="plannotator/herdr-annotate",
            file=Path("nix-config/packages/herdr-annotate.nix"),
            branch_manifest="package.json",
        ),
        "shepherdr": GitHubSourceResource(
            repository="afogel/shepherdr",
            file=Path("nix-config/packages/shepherdr.nix"),
            branch_manifest="Cargo.toml",
        ),
        "omp-undo-redo": NpmResource(
            package="@baylarsadigov/omp-undo-redo",
            file=Path("nix-config/packages/omp-undo-redo.nix"),
        ),
        "ponytail": NpmResource(
            package="@dietrichgebert/ponytail",
            file=Path("nix-config/packages/ponytail.nix"),
        ),
        "qmd": QmdResource(file=Path("nix-config/packages/qmd.nix")),
        "skills-lint-tools": SkillsLintToolsResource(file=Path(".github/workflows/lint-skills.yml")),
    }
)


def request_url(url: str, description: str) -> Request:
    headers = {"User-Agent": "chez-ccamel-update-resource"}
    if token := os.environ.get("GITHUB_TOKEN"):
        headers["Authorization"] = f"Bearer {token}"
    return Request(url, headers=headers)


def fetch_json(url: str, description: str) -> object:
    try:
        with urlopen(request_url(url, description), context=UPSTREAM_SSL_CONTEXT) as response:  # noqa: S310  # URLs are constructed from fixed upstreams.
            return json.load(response)
    except (HTTPError, URLError, OSError, json.JSONDecodeError) as error:
        raise UpdateError(f"could not fetch {description}: {error}") from error


def fetch_text(url: str, description: str) -> str:
    try:
        with urlopen(request_url(url, description), context=UPSTREAM_SSL_CONTEXT) as response:  # noqa: S310  # URLs are constructed from fixed upstreams.
            return response.read().decode()
    except (HTTPError, URLError, OSError, UnicodeDecodeError) as error:
        raise UpdateError(f"could not fetch {description}: {error}") from error


def latest_release(repository: str) -> tuple[str, set[str]]:
    print(f"Fetching latest release for {repository}...", flush=True)
    payload = fetch_json(f"https://api.github.com/repos/{repository}/releases/latest", f"the latest release for {repository}")
    if not isinstance(payload, dict):
        raise UpdateError(f"latest release for {repository} has an invalid response")

    tag = payload.get("tag_name")
    assets = payload.get("assets")
    if not isinstance(tag, str) or not tag:
        raise UpdateError(f"latest release for {repository} has an invalid tag: {tag!r}")
    if not isinstance(assets, list) or any(not isinstance(asset, dict) or not isinstance(asset.get("name"), str) for asset in assets):
        raise UpdateError(f"latest release for {repository} has invalid assets")
    return tag, {asset["name"] for asset in assets}


def latest_release_tag(repository: str) -> str:
    tag, _ = latest_release(repository)
    return tag


def github_commit(repository: str, ref: str) -> tuple[str, str]:
    payload = fetch_json(
        f"https://api.github.com/repos/{repository}/commits/{quote(ref, safe='')}",
        f"commit {ref!r} for {repository}",
    )
    if not isinstance(payload, dict):
        raise UpdateError(f"commit {ref!r} for {repository} has an invalid response")
    revision = payload.get("sha")
    commit = payload.get("commit")
    author = commit.get("author") if isinstance(commit, dict) else None
    date = author.get("date") if isinstance(author, dict) else None
    if not isinstance(revision, str) or not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise UpdateError(f"commit {ref!r} for {repository} has an invalid revision: {revision!r}")
    if not isinstance(date, str):
        raise UpdateError(f"commit {ref!r} for {repository} has an invalid author date: {date!r}")
    try:
        datetime.fromisoformat(date.replace("Z", "+00:00"))
    except ValueError as error:
        raise UpdateError(f"commit {ref!r} for {repository} has an invalid author date: {date!r}") from error
    return revision, date[:10]


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
    tag, available_assets = latest_release(resource.repository)
    if not tag.startswith("v") or len(tag) == 1:
        raise UpdateError(f"latest release for {resource.repository} has an invalid tag: {tag!r}")
    version = tag.removeprefix("v")
    assets = tuple((system, asset.format(version=version)) for system, asset in resource.assets)
    if tuple(system for system, _ in assets) != SYSTEMS:
        raise UpdateError(f"{resource.repository} has unsupported asset system ordering")
    missing_assets = [asset for _, asset in assets if asset not in available_assets]
    if missing_assets:
        raise UpdateError(f"latest release for {resource.repository} is missing assets: {', '.join(missing_assets)}")

    urls = tuple((system, f"https://github.com/{resource.repository}/releases/download/{tag}/{asset}") for system, asset in assets)
    hashes = tuple(prefetch_hash(url) for _, url in urls)
    return ResourceUpdate(
        values=(("version", version), *(("hash", resource_hash) for resource_hash in hashes)),
        output=(
            f"Tag: {tag}",
            *(f"{system} URL: {url}\n{system} hash: {resource_hash}" for (system, url), resource_hash in zip(urls, hashes, strict=True)),
        ),
    )


def fetchurl_update(resource: FetchUrlResource) -> ResourceUpdate:
    resource_hash = prefetch_hash(resource.url)
    return ResourceUpdate(values=(("hash", resource_hash),), output=(f"URL: {resource.url}", f"Hash: {resource_hash}"))


def manifest_version(repository: str, revision: str, manifest: str) -> str:
    contents = fetch_text(
        f"https://raw.githubusercontent.com/{repository}/{revision}/{manifest}",
        f"{manifest} at {revision} for {repository}",
    )
    if manifest == "package.json":
        matches = re.findall(r'"version"\s*:\s*"([^"\\]+)"', contents)
    elif manifest == "Cargo.toml":
        matches = re.findall(r'^version\s*=\s*"([^"\\]+)"\s*$', contents, flags=re.MULTILINE)
    else:
        raise UpdateError(f"unsupported manifest {manifest!r} for {repository}")
    if len(matches) != 1 or not matches[0]:
        raise UpdateError(f"{manifest} at {revision} for {repository} must contain exactly one version")
    return matches[0]


def replacement_line(line: str, name: str, value: str) -> str | None:
    stripped = line.strip()
    prefix = f'{name} = "'
    suffix = '";'
    if not stripped.startswith(prefix) or not stripped.endswith(suffix):
        return None

    indentation = line[: len(line) - len(line.lstrip())]
    newline = "\n" if line.endswith("\n") else ""
    rendered_value = value if value == "lib.fakeHash" else f'"{value}"'
    return f"{indentation}{name} = {rendered_value};{newline}"


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


def update_qmd_hash(contents: str, system: str, resource_hash: str) -> str:
    if system not in SYSTEMS:
        raise UpdateError(f"qmd is unsupported on {system}")
    lines = contents.splitlines(keepends=True)
    markers = [index for index, line in enumerate(lines) if line.strip() == MARKER]
    names = []
    for marker in markers:
        if marker + 1 >= len(lines):
            raise UpdateError("qmd hash marker is not followed by an assignment")
        match = re.fullmatch(r'\s*([a-z0-9_-]+) = "[^"]+";\s*', lines[marker + 1])
        if match is None:
            raise UpdateError("qmd hash marker must be followed by a hash assignment")
        names.append(match.group(1))
    if tuple(names) != SYSTEMS:
        raise UpdateError(f"qmd hash markers must be ordered for {', '.join(SYSTEMS)}")

    marker = markers[SYSTEMS.index(system)]
    replacement = replacement_line(lines[marker + 1], system, resource_hash)
    assert replacement is not None
    lines[marker + 1] = replacement
    return "".join(lines)


def build_expression(package_file: Path) -> str:
    return (
        "let "
        "flake = builtins.getFlake (toString ./nix-config); "
        "pkgs = import flake.inputs.nixpkgs { system = builtins.currentSystem; }; "
        f"package = import {json.dumps(str(package_file.resolve()))}; "
        "arguments = builtins.functionArgs package; "
        "in pkgs.callPackage package ("
        "(pkgs.lib.optionalAttrs (arguments ? omp) { "
        "omp = flake.inputs.omp.packages.${builtins.currentSystem}.omp; "
        "}) // "
        "(pkgs.lib.optionalAttrs (arguments ? herdr) { "
        "herdr = pkgs.callPackage ./nix-config/packages/herdr.nix { }; "
        "}) // "
        "(pkgs.lib.optionalAttrs (arguments ? src) { src = flake.inputs.qmd; }) // "
        "(pkgs.lib.optionalAttrs (arguments ? upstreamQmd) { "
        "upstreamQmd = flake.inputs.qmd.packages.${builtins.currentSystem}.qmd; "
        "})"
        ")"
    )


def fake_build_hash(package_file: Path, contents: str) -> str:
    with tempfile.TemporaryDirectory(prefix="update-resource-") as temporary_directory:
        candidate = Path(temporary_directory) / package_file.name
        candidate.write_text(contents)
        result = subprocess.run(
            ["nix", "build", "--no-link", "--impure", "--expr", build_expression(candidate)],
            check=False,
            cwd=ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
    if result.returncode == 0:
        raise UpdateError(f"Nix accepted lib.fakeHash while building {package_file}")
    hashes = re.findall(r"got:\s*(sha256-[A-Za-z0-9+/=]+)", f"{result.stdout}\n{result.stderr}")
    if len(hashes) != 1:
        raise UpdateError(f"Nix did not return exactly one source hash while building {package_file}")
    return hashes[0]


def source_update(resource: GitHubSourceResource) -> ResourceUpdate:
    if resource.branch_manifest is None:
        tag, _ = latest_release(resource.repository)
        version = tag.removeprefix("v")
        revision, _ = github_commit(resource.repository, tag)
        output = (f"Tag: {tag}",)
    else:
        revision, date = github_commit(resource.repository, "main")
        version = f"{manifest_version(resource.repository, revision, resource.branch_manifest)}-unstable-{date}"
        output = ("Branch: main",)
    candidate_values = (("version", version), ("rev", revision), ("hash", "lib.fakeHash"))
    contents = (ROOT / resource.file).read_text()
    resource_hash = fake_build_hash(resource.file, update_marked_values(contents, candidate_values))
    return ResourceUpdate(values=(("version", version), ("rev", revision), ("hash", resource_hash)), output=(*output, f"Revision: {revision}", f"Hash: {resource_hash}"))


def npm_update(resource: NpmResource) -> ResourceUpdate:
    payload = fetch_json(
        f"https://registry.npmjs.org/{quote(resource.package, safe='')}/latest",
        f"the latest npm metadata for {resource.package}",
    )
    dist = payload.get("dist") if isinstance(payload, dict) else None
    version = payload.get("version") if isinstance(payload, dict) else None
    integrity = dist.get("integrity") if isinstance(dist, dict) else None
    if not isinstance(version, str) or not version or not isinstance(integrity, str) or not integrity:
        raise UpdateError(f"latest npm metadata for {resource.package} must include string version and dist.integrity")
    return ResourceUpdate(values=(("version", version), ("hash", integrity)), output=(f"Version: {version}", f"Integrity: {integrity}"))


def current_system() -> str:
    try:
        result = subprocess.run(
            ["nix", "eval", "--raw", "--impure", "--expr", "builtins.currentSystem"],
            check=True,
            stdout=subprocess.PIPE,
            stderr=sys.stderr,
            text=True,
        )
    except subprocess.CalledProcessError as error:
        raise UpdateError(f"could not determine the current Nix system: {error}") from error
    system = result.stdout.strip()
    if system not in SYSTEMS:
        raise UpdateError(f"qmd is unsupported on {system}")
    return system


def qmd_update(resource: QmdResource) -> ResourceUpdate:
    system = current_system()
    contents = (ROOT / resource.file).read_text()
    resource_hash = fake_build_hash(resource.file, update_qmd_hash(contents, system, "lib.fakeHash"))
    return ResourceUpdate(values=((system, resource_hash),), output=(f"System: {system}", f"Hash: {resource_hash}"))


def replace_once(contents: str, pattern: str, replacement: str, description: str) -> str:
    matches = list(re.finditer(pattern, contents, flags=re.MULTILINE))
    if len(matches) != 1:
        raise UpdateError(f"expected exactly one {description} pin, found {len(matches)}")
    return re.sub(pattern, replacement, contents, count=1, flags=re.MULTILINE)


def skills_lint_tools_update(_resource: SkillsLintToolsResource) -> ResourceUpdate:
    uv_tag = latest_release_tag("astral-sh/uv")
    node_payload = fetch_json("https://nodejs.org/dist/index.json", "the Node.js release index")
    if not isinstance(node_payload, list):
        raise UpdateError("Node.js release index has an invalid response")
    node_versions = []
    for entry in node_payload:
        version = entry.get("version") if isinstance(entry, dict) else None
        match = re.fullmatch(r"v24\.(\d+)\.(\d+)", version) if isinstance(version, str) else None
        if match:
            node_versions.append(((int(match.group(1)), int(match.group(2))), version.removeprefix("v")))
    if not node_versions:
        raise UpdateError("Node.js release index has no stable v24 release")
    node_version = max(node_versions)[1]
    skills_revision, _ = github_commit("agentskills/agentskills", "main")
    skill_payload = fetch_json("https://registry.npmjs.org/skill-check/latest", "the latest npm metadata for skill-check")
    skill_version = skill_payload.get("version") if isinstance(skill_payload, dict) else None
    if not isinstance(skill_version, str) or not skill_version:
        raise UpdateError("latest npm metadata for skill-check must include a string version")
    return ResourceUpdate(
        values=(("uv-version", uv_tag.removeprefix("v")), ("node-version", node_version), ("skills-ref", skills_revision), ("skill-check", skill_version)),
        output=(f"uv: {uv_tag}", f"Node.js: {node_version}", f"skills-ref: {skills_revision}", f"skill-check: {skill_version}"),
    )


def update_skills_lint_tools(contents: str, values: tuple[tuple[str, str], ...]) -> str:
    pins = dict(values)
    if set(pins) != {"uv-version", "node-version", "skills-ref", "skill-check"}:
        raise UpdateError("skills-lint-tools returned incomplete pin metadata")
    contents = replace_once(contents, r"^          uv-version: '[^']+'$", f"          uv-version: '{pins['uv-version']}'", "uv-version")
    contents = replace_once(contents, r"^          node-version: '[^']+'$", f"          node-version: '{pins['node-version']}'", "node-version")
    contents = replace_once(
        contents,
        r"^        run: uv tool install git\+https://github\.com/agentskills/agentskills\.git@[0-9a-f]{40}#subdirectory=skills-ref$",
        f"        run: uv tool install git+https://github.com/agentskills/agentskills.git@{pins['skills-ref']}#subdirectory=skills-ref",
        "skills-ref",
    )
    return replace_once(contents, r"^        run: npx skill-check@[0-9][^ ]* check --no-security-scan \.agents/skills$", f"        run: npx skill-check@{pins['skill-check']} check --no-security-scan .agents/skills", "skill-check")


def collect_update(resource: Resource) -> ResourceUpdate:
    if isinstance(resource, GitHubReleaseResource):
        return release_update(resource)
    if isinstance(resource, FetchUrlResource):
        return fetchurl_update(resource)
    if isinstance(resource, GitHubSourceResource):
        return source_update(resource)
    if isinstance(resource, NpmResource):
        return npm_update(resource)
    if isinstance(resource, QmdResource):
        return qmd_update(resource)
    return skills_lint_tools_update(resource)


def apply_update(resource: Resource, update: ResourceUpdate) -> str:
    contents = (ROOT / resource.file).read_text()
    if isinstance(resource, QmdResource):
        return update_qmd_hash(contents, update.values[0][0], update.values[0][1])
    if isinstance(resource, SkillsLintToolsResource):
        return update_skills_lint_tools(contents, update.values)
    return update_marked_values(contents, update.values)


def run_post_update_checks(resource: Resource) -> int:
    if isinstance(resource, SkillsLintToolsResource):
        return 0
    commands = (
        ("formatting", ["just", "fmt"]),
        ("targeted Nix build", ["nix", "build", "--no-link", "--impure", "--expr", build_expression(ROOT / resource.file)]),
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
        subprocess.run(["git", "--no-pager", "diff", "--", resource.file.as_posix()], stdout=sys.stdout, stderr=sys.stderr, check=False, cwd=ROOT)

    return 1 if failed else 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("resources", nargs="*", choices=RESOURCES, help="resource to update")
    return parser.parse_args()


def update_resource(name: str) -> int:
    resource = RESOURCES[name]
    print(f"Updating {name}...", flush=True)

    try:
        update = collect_update(resource)
        updated = apply_update(resource, update)
    except (OSError, UpdateError) as error:
        print(f"update-resource: {error}", file=sys.stderr)
        return 1

    for line in update.output:
        print(line, flush=True)

    package_file = ROOT / resource.file
    print(f"Writing {package_file}...", flush=True)
    package_file.write_text(updated)
    return run_post_update_checks(resource)


def main() -> int:
    args = parse_args()
    for name in args.resources or RESOURCES:
        if update_resource(name):
            return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
