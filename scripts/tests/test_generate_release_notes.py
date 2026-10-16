from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "generate-release-notes.py"


class GenerateReleaseNotesTest(unittest.TestCase):
    def setUp(self) -> None:
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.repository = Path(self.temporary.name)
        self.git("init", "--initial-branch=main")
        self.git("config", "user.name", "Release notes test")
        self.git("config", "user.email", "release@example.invalid")
        self.git("config", "commit.gpgsign", "false")
        self.git("config", "core.hooksPath", "/dev/null")
        self.commit(":sparkles: Old feature")
        self.git("tag", "previous")

    def git(self, *args: str) -> str:
        return subprocess.run(
            ["git", *args], cwd=self.repository, check=True, capture_output=True, text=True
        ).stdout.strip()

    def commit(self, subject: str) -> str:
        self.git("commit", "--allow-empty", "-m", subject)
        return self.git("rev-parse", "HEAD")

    def generate(self, previous: str = "previous", current: str = "current") -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [sys.executable, str(SCRIPT_PATH), previous, current, "owner/repository"],
            cwd=self.repository,
            capture_output=True,
            text=True,
        )

    def test_includes_direct_and_merged_commits_with_exact_release_boundaries(self) -> None:
        self.git("switch", "-c", "fix")
        fix = self.commit(":bug: Repair tool configuration")
        self.git("switch", "main")
        feature = self.commit(":sparkles: Add toolbox directly on main")
        self.git("merge", "--no-ff", "fix", "-m", "Merge fix branch")
        dependency = self.commit(":arrow_up: Update installed tools")
        other = self.commit("Adjust shell settings")
        self.git("tag", "current")
        self.commit(":sparkles: Feature after release")

        result = self.generate()

        self.assertEqual(result.returncode, 0, result.stderr)
        features, fixes = result.stdout.split("## Fixes", 1)
        self.assertIn(f"Add toolbox directly on main ([{feature[:7]}]", features)
        self.assertIn("## Features", features)
        self.assertIn(f"Repair tool configuration ([{fix[:7]}]", fixes.split("## Dependency updates", 1)[0])
        self.assertIn(f"Update installed tools ([{dependency[:7]}]", result.stdout)
        self.assertIn(f"Adjust shell settings ([{other[:7]}]", result.stdout.split("## Other changes", 1)[1])
        for sha in (feature, fix, dependency, other):
            self.assertEqual(result.stdout.count(f"https://github.com/owner/repository/commit/{sha}"), 1)
        self.assertNotIn("Old feature", result.stdout)
        self.assertNotIn("Feature after release", result.stdout)
        self.assertNotIn("Merge fix branch", result.stdout)
        self.assertIn("https://github.com/owner/repository/compare/previous...current", result.stdout)

    def test_separates_features_from_dependency_additions_and_removals(self) -> None:
        self.commit(":sparkles: Install new toolbox tool")
        self.commit(":heavy_plus_sign: Add library dependency")
        self.commit(":heavy_minus_sign: Remove unused library")
        self.git("tag", "current")

        result = self.generate()

        self.assertEqual(result.returncode, 0, result.stderr)
        features, dependencies = result.stdout.split("## Dependency updates", 1)
        self.assertIn("Install new toolbox tool", features)
        for subject in ("Add library dependency", "Remove unused library"):
            self.assertIn(subject, dependencies)
            self.assertNotIn(subject, features)
        self.assertNotIn("Install new toolbox tool", dependencies)
        self.assertNotIn("## Other changes", result.stdout)

    def test_keeps_breaking_changes_before_features(self) -> None:
        self.commit(":boom: Remove old configuration interface")
        self.commit(":sparkles: Add new interface")
        self.git("tag", "current")

        result = self.generate()

        self.assertEqual(result.returncode, 0, result.stderr)
        breaking, features = result.stdout.split("## Features", 1)
        self.assertIn("## Breaking changes", breaking)
        self.assertIn("Remove old configuration interface", breaking)
        self.assertIn("Add new interface", features)

    def test_invalid_release_boundary_fails_without_partial_notes(self) -> None:
        result = self.generate(current="missing-release")

        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, "")
        self.assertIn("generate-release-notes:", result.stderr)


if __name__ == "__main__":
    unittest.main()
