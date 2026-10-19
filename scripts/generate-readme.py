#!/usr/bin/env python3
"""Render curated README tables from Nix metadata."""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


SECTIONS = ("core", "neovim_plugins", "agentic", "devops")
README_SYSTEM = "x86_64-linux"
NEOVIM_LOCKFILE = Path("nix-config/home/modules/neovim/config/lazy-lock.json")

FIELDS = frozenset(("name", "version", "description", "url", "visibility"))
GROUP_FIELDS = frozenset(("name", "description", "items"))
AGENTIC_FIELDS = frozenset(("description", "groups"))
NEOVIM_PLUGIN_FIELDS = frozenset(("branch", "commit"))
VISIBILITIES = frozenset(("public", "private"))


class GenerationError(Exception):
    """Raised when README metadata or markers are invalid."""


def evaluate_metadata(repository_root: Path) -> Any:
    result = subprocess.run(
        ["nix", "eval", "--json", f"./nix-config#lib.readmeDocumentation.{README_SYSTEM}"],
        cwd=repository_root,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode:
        detail = result.stderr.strip() or result.stdout.strip()
        raise GenerationError(f"Nix evaluation failed: {detail}")

    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError as error:
        raise GenerationError(f"Nix evaluation did not return valid JSON: {error}") from error

def evaluate_neovim_plugins(repository_root: Path) -> Any:
    try:
        return json.loads((repository_root / NEOVIM_LOCKFILE).read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        raise GenerationError(f"Neovim plugin lockfile is not valid JSON: {error}") from error


def validate_neovim_plugins(plugins: Any) -> dict[str, dict[str, str]]:
    if not isinstance(plugins, dict) or not plugins:
        raise GenerationError("Neovim plugin lockfile must contain at least one plugin")

    for name, plugin in plugins.items():
        if not isinstance(name, str) or not isinstance(plugin, dict) or set(plugin) != NEOVIM_PLUGIN_FIELDS:
            raise GenerationError(f"Neovim plugin {name!r} must contain exactly {sorted(NEOVIM_PLUGIN_FIELDS)}")
        if any(not isinstance(value, str) or not value for value in plugin.values()):
            raise GenerationError(f"Neovim plugin {name!r} branch and commit must be non-empty strings")
    return plugins


def validate_items(section: str, items: Any) -> list[dict[str, str]]:
    if not isinstance(items, list):
        raise GenerationError(f"{section} metadata must be a list")

    names: set[str] = set()
    public_items = 0
    validated_items: list[dict[str, str]] = []
    for index, item in enumerate(items):
        if not isinstance(item, dict) or set(item) != FIELDS:
            raise GenerationError(f"{section} item {index} must contain exactly {sorted(FIELDS)}")
        if any(not isinstance(item[field], str) for field in FIELDS - {"version"}):
            raise GenerationError(f"{section} item {index} non-version fields must all be strings")
        if item["version"] is not None and not isinstance(item["version"], str):
            raise GenerationError(f"{section} item {index} version must be a string or null")
        if item["visibility"] not in VISIBILITIES:
            raise GenerationError(
                f"{section} item {index} has unsupported visibility {item['visibility']!r}"
            )
        if item["name"] in names:
            raise GenerationError(f"{section} metadata contains duplicate name {item['name']!r}")

        names.add(item["name"])
        public_items += item["visibility"] == "public"
        validated_items.append(item)

    if not public_items:
        raise GenerationError(f"{section} metadata must contain at least one public item")
    return validated_items


def validate_agentic_section(metadata: Any) -> dict[str, Any]:
    if not isinstance(metadata, dict) or set(metadata) != AGENTIC_FIELDS:
        raise GenerationError("agentic metadata must contain exactly description and groups")
    if not isinstance(metadata["description"], str):
        raise GenerationError("agentic description must be a string")
    if not isinstance(metadata["groups"], list):
        raise GenerationError("agentic groups must be a list")

    names: set[str] = set()
    groups: list[dict[str, Any]] = []
    for index, group in enumerate(metadata["groups"]):
        if not isinstance(group, dict) or set(group) != GROUP_FIELDS:
            raise GenerationError(f"agentic group {index} must contain exactly {sorted(GROUP_FIELDS)}")
        if not isinstance(group["name"], str) or not isinstance(group["description"], str):
            raise GenerationError(f"agentic group {index} name and description must be strings")
        if group["name"] in names:
            raise GenerationError(f"agentic metadata contains duplicate group {group['name']!r}")

        names.add(group["name"])
        groups.append(
            {
                "name": group["name"],
                "description": group["description"],
                "items": validate_items(f"agentic group {group['name']!r}", group["items"]),
            }
        )

    if not groups:
        raise GenerationError("agentic metadata must contain at least one group")
    return {"description": metadata["description"], "groups": groups}


def validate_metadata(metadata: Any) -> dict[str, Any]:
    if not isinstance(metadata, dict) or set(metadata) != {"core", "agentic", "devops"}:
        raise GenerationError("metadata must contain only core, agentic, and devops sections")

    return {
        "core": validate_items("core", metadata["core"]),
        "agentic": validate_agentic_section(metadata["agentic"]),
        "devops": validate_items("devops", metadata["devops"]),
    }


def escape_table_cell(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace("|", "\\|")
        .replace("\r\n", "<br>")
        .replace("\r", "<br>")
        .replace("\n", "<br>")
    )


def render_table(
    items: list[dict[str, str]], name_heading: str = "Tool", description_heading: str = "Description"
) -> str:
    public_items = (item for item in items if item["visibility"] == "public")
    rows = [f"| {name_heading} | {description_heading} |", "| --- | --- |"]
    for item in sorted(public_items, key=lambda item: item["name"].casefold()):
        display_name = f"{item['name']} v{item['version']}" if item["version"] else item["name"]
        name = escape_table_cell(display_name).replace("[", "\\[").replace("]", "\\]")
        url = item["url"].replace("\\", "\\\\").replace(")", "\\)")
        description = escape_table_cell(item["description"])
        rows.append(f"| [{name}]({url}) | {description} |")
    return "\n".join(rows)

def render_neovim_plugins(plugins: Any) -> str:
    rows = ["| Plugin | Branch | Commit |", "| --- | --- | --- |"]
    for name, plugin in sorted(validate_neovim_plugins(plugins).items(), key=lambda item: item[0].casefold()):
        rows.append(f"| {escape_table_cell(name)} | {escape_table_cell(plugin['branch'])} | `{plugin['commit'][:7]}` |")
    return "\n".join(rows)


def render_agentic_section(section: dict[str, Any]) -> str:
    rows = [section["description"]]
    for group in section["groups"]:
        rows.extend(
            [
                "",
                f"#### {group['name']}",
                "",
                group["description"],
                "",
                render_table(group["items"], "Component", "Role"),
            ]
        )
    return "\n".join(rows)


def render_tables(metadata: Any) -> dict[str, str]:
    validated = validate_metadata(metadata)
    return {
        "core": render_table(validated["core"]),
        "agentic": render_agentic_section(validated["agentic"]),
        "devops": render_table(validated["devops"]),
    }


def marker_matches(readme: str) -> dict[str, tuple[re.Match[str], re.Match[str]]]:
    matches: dict[str, tuple[re.Match[str], re.Match[str]]] = {}
    ordered_matches: list[tuple[int, str]] = []
    for section in SECTIONS:
        marker = section.upper()
        begin = list(re.finditer(rf"^<!-- BEGIN_GENERATED_{marker} -->\r?$", readme, re.MULTILINE))
        end = list(re.finditer(rf"^<!-- END_GENERATED_{marker} -->\r?$", readme, re.MULTILINE))
        if len(begin) != 1 or len(end) != 1:
            raise GenerationError(f"{section} markers must each occur exactly once")
        matches[section] = (begin[0], end[0])
        ordered_matches.extend(((begin[0].start(), f"BEGIN_{marker}"), (end[0].start(), f"END_{marker}")))

    expected_order = [
        marker
        for section in SECTIONS
        for marker in (f"BEGIN_{section.upper()}", f"END_{section.upper()}")
    ]
    actual_order = [marker for _, marker in sorted(ordered_matches)]
    if actual_order != expected_order:
        raise GenerationError("generated README markers are in the wrong order")

    return matches


def replace_generated_sections(readme: str, tables: dict[str, str]) -> str:
    matches = marker_matches(readme)
    line_ending = "\r\n" if "\r\n" in readme else "\n"
    rendered = readme
    for section in reversed(SECTIONS):
        begin, end = matches[section]
        interior = f"{line_ending}{tables[section].replace(chr(10), line_ending)}{line_ending}"
        rendered = f"{rendered[:begin.end()]}{interior}{rendered[end.start():]}"
    return rendered


def write_readme(path: Path, content: str) -> None:
    with tempfile.NamedTemporaryFile("w", dir=path.parent, encoding="utf-8", delete=False) as temporary:
        temporary.write(content)
        temporary_path = Path(temporary.name)
    os.chmod(temporary_path, path.stat().st_mode)
    temporary_path.replace(path)


def generate_readme(repository_root: Path, check: bool) -> bool:
    readme_path = repository_root / "README.md"
    original = readme_path.read_text(encoding="utf-8")
    tables = render_tables(evaluate_metadata(repository_root))
    tables["neovim_plugins"] = render_neovim_plugins(evaluate_neovim_plugins(repository_root))
    updated = replace_generated_sections(original, tables)
    if updated == original:
        return True
    if check:
        print("README.md is out of date; run `just generate-readme`.", file=sys.stderr)
        return False

    write_readme(readme_path, updated)
    return True


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="fail instead of updating README.md")
    args = parser.parse_args(argv)
    repository_root = Path(__file__).resolve().parent.parent

    try:
        return 0 if generate_readme(repository_root, args.check) else 1
    except (GenerationError, OSError) as error:
        print(f"generate-readme: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
