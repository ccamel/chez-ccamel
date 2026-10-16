#!/usr/bin/env python3
"""Generate Gitmoji-grouped release notes from all non-merge commits in a Git range.

Follow the repository's Gitmoji policy: new tools are features; adding or removing
dependencies belongs under Dependency updates.
"""

from __future__ import annotations

import argparse
import subprocess
import sys


GROUPS = {
    "Breaking changes": {":boom:"},
    "Features": {":sparkles:"},
    "Fixes": {":bug:", ":ambulance:", ":lock:"},
    "Dependency updates": {":arrow_up:", ":arrow_down:", ":pushpin:", ":heavy_plus_sign:", ":heavy_minus_sign:"},
    "Other changes": set(),
}


def generate_notes(previous: str, current: str, repository: str) -> str:
    commits = subprocess.run(
        ["git", "log", "--no-merges", "--format=%H%x00%s", f"{previous}..{current}", "--"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
        encoding="utf-8",
    ).stdout
    url = f"https://github.com/{repository}"
    groups: dict[str, list[str]] = {title: [] for title in GROUPS}
    for line in commits.splitlines():
        sha, subject = line.split("\0", 1)
        kind = subject.partition(" ")[0]
        group = next((title for title, kinds in GROUPS.items() if kind in kinds), "Other changes")
        groups[group].append(f"- {subject} ([{sha[:7]}]({url}/commit/{sha}))")

    notes = []
    for title, entries in groups.items():
        if entries:
            notes.extend((f"## {title}", "", *entries, ""))
    notes.append(f"**Full Changelog**: {url}/compare/{previous}...{current}")
    return "\n".join(notes) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("previous", help="exclusive start tag or commit")
    parser.add_argument("current", help="inclusive end tag or commit")
    parser.add_argument("repository", help="GitHub owner/repository for commit links")
    args = parser.parse_args(argv)
    try:
        notes = generate_notes(args.previous, args.current, args.repository)
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"generate-release-notes: {error}", file=sys.stderr)
        return 1
    print(notes, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
