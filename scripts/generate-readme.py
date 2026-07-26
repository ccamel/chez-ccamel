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


SECTIONS = ("core", "agentic", "devops")
FIELDS = frozenset(("name", "description", "url", "visibility"))
VISIBILITIES = frozenset(("public", "private"))


class GenerationError(Exception):
    """Raised when README metadata or markers are invalid."""


def evaluate_metadata(repository_root: Path) -> Any:
    result = subprocess.run(
        ["nix", "eval", "--json", "./nix-config#readmeDocumentation"],
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


def validate_metadata(metadata: Any) -> dict[str, list[dict[str, str]]]:
    if not isinstance(metadata, dict) or set(metadata) != set(SECTIONS):
        raise GenerationError("metadata must contain only core, agentic, and devops sections")

    validated: dict[str, list[dict[str, str]]] = {}
    for section in SECTIONS:
        items = metadata[section]
        if not isinstance(items, list):
            raise GenerationError(f"{section} metadata must be a list")

        names: set[str] = set()
        public_items = 0
        validated_items: list[dict[str, str]] = []
        for index, item in enumerate(items):
            if not isinstance(item, dict) or set(item) != FIELDS:
                raise GenerationError(f"{section} item {index} must contain exactly {sorted(FIELDS)}")
            if any(not isinstance(item[field], str) for field in FIELDS):
                raise GenerationError(f"{section} item {index} fields must all be strings")
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
        validated[section] = validated_items

    return validated


def escape_table_cell(value: str) -> str:
    return (
        value.replace("\\", "\\\\")
        .replace("|", "\\|")
        .replace("\r\n", "<br>")
        .replace("\r", "<br>")
        .replace("\n", "<br>")
    )


def render_table(items: list[dict[str, str]]) -> str:
    public_items = (item for item in items if item["visibility"] == "public")
    rows = ["| Tool | Description |", "| --- | --- |"]
    for item in sorted(public_items, key=lambda item: item["name"].casefold()):
        name = escape_table_cell(item["name"]).replace("[", "\\[").replace("]", "\\]")
        url = item["url"].replace("\\", "\\\\").replace(")", "\\)")
        description = escape_table_cell(item["description"])
        rows.append(f"| [{name}]({url}) | {description} |")
    return "\n".join(rows)


def render_tables(metadata: Any) -> dict[str, str]:
    return {section: render_table(items) for section, items in validate_metadata(metadata).items()}


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
    updated = replace_generated_sections(original, render_tables(evaluate_metadata(repository_root)))
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
