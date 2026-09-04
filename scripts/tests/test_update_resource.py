from __future__ import annotations

import importlib.util
from pathlib import Path
from types import SimpleNamespace
import sys
import tempfile
import unittest
from unittest.mock import patch


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "update-resource.py"
SPEC = importlib.util.spec_from_file_location("update_resource", SCRIPT_PATH)
assert SPEC and SPEC.loader
UPDATER = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = UPDATER
SPEC.loader.exec_module(UPDATER)


HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
REVISION = "a" * 40


def marked(*assignments: tuple[str, str]) -> str:
    return "".join(f'{UPDATER.MARKER}\n{name} = "{value}";\n' for name, value in assignments)


def skills_workflow() -> str:
    return """          uv-version: '0.1.0'
          node-version: '24.0.0'
        run: uv tool install git+https://github.com/agentskills/agentskills.git@aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa#subdirectory=skills-ref
        run: npx skill-check@1.0.0 check --no-security-scan .agents/skills
"""


class UpdateResourceTest(unittest.TestCase):
    def test_release_collection_requires_expected_assets(self) -> None:
        resource = UPDATER.GitHubReleaseResource("owner/repo", Path("package.nix"), (("x86_64-linux", "linux-{version}"), ("aarch64-darwin", "darwin-{version}")))
        with patch.object(UPDATER, "latest_release", return_value=("v1.2.3", {"linux-1.2.3", "darwin-1.2.3"})), patch.object(UPDATER, "prefetch_hash", side_effect=(HASH, HASH)):
            update = UPDATER.release_update(resource)
        self.assertEqual(update.values, (("version", "1.2.3"), ("hash", HASH), ("hash", HASH)))

        with patch.object(UPDATER, "latest_release", return_value=("v1.2.3", {"linux-1.2.3"})):
            with self.assertRaisesRegex(UPDATER.UpdateError, "missing assets"):
                UPDATER.release_update(resource)

    def test_fetchurl_collection_rejects_missing_prefetch_hash(self) -> None:
        resource = UPDATER.FetchUrlResource("https://example.invalid/source", Path("package.nix"))
        with patch.object(UPDATER, "prefetch_hash", return_value=HASH):
            self.assertEqual(UPDATER.fetchurl_update(resource).values, (("hash", HASH),))
        with patch.object(UPDATER.subprocess, "run", return_value=SimpleNamespace(stdout="{}")):
            with self.assertRaisesRegex(UPDATER.UpdateError, "did not return a hash"):
                UPDATER.prefetch_hash(resource.url)

    def test_source_collection_derives_unstable_version_and_fake_hash(self) -> None:
        resource = UPDATER.GitHubSourceResource("owner/repo", Path("package.nix"), "package.json")
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / resource.file).write_text(marked(("version", "0"), ("rev", REVISION), ("hash", HASH)))
            with patch.object(UPDATER, "ROOT", root), patch.object(UPDATER, "github_commit", return_value=(REVISION, "2026-01-02")), patch.object(UPDATER, "manifest_version", return_value="3.4.5"), patch.object(UPDATER, "fake_build_hash", return_value=HASH) as fake_build:
                update = UPDATER.source_update(resource)
        self.assertEqual(update.values, (("version", "3.4.5-unstable-2026-01-02"), ("rev", REVISION), ("hash", HASH)))
        self.assertIn("lib.fakeHash", fake_build.call_args.args[1])

    def test_source_release_uses_tag_and_tag_commit(self) -> None:
        resource = UPDATER.GitHubSourceResource("owner/repo", Path("package.nix"))
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / resource.file).write_text(marked(("version", "0"), ("rev", REVISION), ("hash", HASH)))
            with patch.object(UPDATER, "ROOT", root), patch.object(UPDATER, "latest_release", return_value=("v2.3.4", set())), patch.object(UPDATER, "github_commit", return_value=(REVISION, "2026-01-02")), patch.object(UPDATER, "fake_build_hash", return_value=HASH):
                update = UPDATER.source_update(resource)
        self.assertEqual(update.values, (("version", "2.3.4"), ("rev", REVISION), ("hash", HASH)))

    def test_source_manifest_requires_exactly_one_version(self) -> None:
        with patch.object(UPDATER, "fetch_text", return_value='{"version": "1.0.0", "nested": {"version": "2.0.0"}}'):
            with self.assertRaisesRegex(UPDATER.UpdateError, "exactly one version"):
                UPDATER.manifest_version("owner/repo", REVISION, "package.json")
        with patch.object(UPDATER, "fetch_text", return_value='[package]\nversion = "1.0.0"\n'):
            self.assertEqual(UPDATER.manifest_version("owner/repo", REVISION, "Cargo.toml"), "1.0.0")

    def test_fake_source_build_extracts_only_nix_reported_hash(self) -> None:
        result = SimpleNamespace(returncode=1, stdout="", stderr=f"error: hash mismatch\n  got: {HASH}\n")
        with patch.object(UPDATER.subprocess, "run", return_value=result):
            self.assertEqual(UPDATER.fake_build_hash(Path("package.nix"), marked(("hash", "lib.fakeHash"))), HASH)
        with patch.object(UPDATER.subprocess, "run", return_value=SimpleNamespace(returncode=1, stdout="", stderr="hash mismatch")):
            with self.assertRaisesRegex(UPDATER.UpdateError, "exactly one source hash"):
                UPDATER.fake_build_hash(Path("package.nix"), "")

    def test_npm_collection_uses_registry_integrity(self) -> None:
        resource = UPDATER.NpmResource("@scope/package", Path("package.nix"))
        with patch.object(UPDATER, "fetch_json", return_value={"version": "2.0.0", "dist": {"integrity": "sha512-registry"}}):
            self.assertEqual(UPDATER.npm_update(resource).values, (("version", "2.0.0"), ("hash", "sha512-registry")))
        with patch.object(UPDATER, "fetch_json", return_value={"version": "2.0.0", "dist": {}}):
            with self.assertRaisesRegex(UPDATER.UpdateError, "dist.integrity"):
                UPDATER.npm_update(resource)

    def test_qmd_updates_only_the_native_hash(self) -> None:
        resource = UPDATER.QmdResource(Path("qmd.nix"))
        contents = marked(("x86_64-linux", HASH), ("aarch64-darwin", "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="))
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            (root / resource.file).write_text(contents)
            with patch.object(UPDATER, "ROOT", root), patch.object(UPDATER, "current_system", return_value="x86_64-linux"), patch.object(UPDATER, "fake_build_hash", return_value="sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="):
                update = UPDATER.qmd_update(resource)
                updated = UPDATER.apply_update(resource, update)
        self.assertIn('x86_64-linux = "sha256-CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=";', updated)
        self.assertIn('aarch64-darwin = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";', updated)
        with self.assertRaisesRegex(UPDATER.UpdateError, "ordered"):
            UPDATER.update_qmd_hash(marked(("aarch64-darwin", HASH), ("x86_64-linux", HASH)), "x86_64-linux", HASH)

    def test_omp_release_updates_its_flake_input_and_lock(self) -> None:
        resource = UPDATER.FlakeInputReleaseResource("can1357/oh-my-pi", "omp", Path("nix-config/flake.nix"))
        original = '    omp.url = "github:can1357/oh-my-pi/v18.0.11";\n'
        with patch.object(UPDATER, "latest_release_tag", return_value="v18.1.10"):
            update = UPDATER.flake_input_release_update(resource)
        self.assertEqual(update.values, (("tag", "v18.1.10"),))
        self.assertEqual(UPDATER.update_flake_input(original, resource, "v18.1.10"), '    omp.url = "github:can1357/oh-my-pi/v18.1.10";\n')
        with patch.object(UPDATER.subprocess, "run") as run:
            UPDATER.sync_flake_input(resource)
        run.assert_called_once_with(["nix", "flake", "update", "--flake", "./nix-config", "omp"], check=True, cwd=UPDATER.ROOT, stdout=UPDATER.sys.stdout, stderr=UPDATER.sys.stderr)
        with self.assertRaisesRegex(UPDATER.UpdateError, "omp input pin, found 0"):
            UPDATER.update_flake_input("", resource, "v18.1.10")

    def test_skills_lint_tools_collects_and_replaces_all_pins(self) -> None:
        resource = UPDATER.SkillsLintToolsResource(Path("lint-skills.yml"))
        node_index = [{"version": "v24.2.1"}, {"version": "v24.10.0"}, {"version": "v25.0.0"}, {"version": "v24.11.0-rc.1"}]
        with patch.object(UPDATER, "latest_release_tag", return_value="0.9.0"), patch.object(UPDATER, "github_commit", return_value=(REVISION, "2026-01-01")), patch.object(UPDATER, "fetch_json", side_effect=(node_index, {"version": "2.3.4"})):
            update = UPDATER.skills_lint_tools_update(resource)
        updated = UPDATER.update_skills_lint_tools(skills_workflow(), update.values)
        self.assertIn("uv-version: '0.9.0'", updated)
        self.assertIn("node-version: '24.10.0'", updated)
        self.assertIn(f"agentskills.git@{REVISION}", updated)
        self.assertIn("skill-check@2.3.4", updated)

    def test_skills_lint_tools_rejects_malformed_sources_and_pin_counts(self) -> None:
        resource = UPDATER.SkillsLintToolsResource(Path("lint-skills.yml"))
        with patch.object(UPDATER, "latest_release_tag", return_value="0.9.0"), patch.object(UPDATER, "fetch_json", return_value=[]):
            with self.assertRaisesRegex(UPDATER.UpdateError, "no stable v24"):
                UPDATER.skills_lint_tools_update(resource)
        values = (("uv-version", "0.9.0"), ("node-version", "24.10.0"), ("skills-ref", REVISION), ("skill-check", "2.3.4"))
        pins = {
            "uv-version": "          uv-version: '0.1.0'\n",
            "node-version": "          node-version: '24.0.0'\n",
            "skills-ref": f"        run: uv tool install git+https://github.com/agentskills/agentskills.git@{REVISION}#subdirectory=skills-ref\n",
            "skill-check": "        run: npx skill-check@1.0.0 check --no-security-scan .agents/skills\n",
        }
        for name, pin in pins.items():
            with self.subTest(name=name, count=0):
                with self.assertRaisesRegex(UPDATER.UpdateError, f"{name} pin, found 0"):
                    UPDATER.update_skills_lint_tools(skills_workflow().replace(pin, ""), values)
            with self.subTest(name=name, count=2):
                with self.assertRaisesRegex(UPDATER.UpdateError, f"{name} pin, found 2"):
                    UPDATER.update_skills_lint_tools(skills_workflow() + pin, values)

    def test_markers_require_exact_count_and_order(self) -> None:
        with self.assertRaisesRegex(UPDATER.UpdateError, "exactly 2"):
            UPDATER.update_marked_values(marked(("version", "1")), (("version", "2"), ("hash", HASH)))
        with self.assertRaisesRegex(UPDATER.UpdateError, "version marker"):
            UPDATER.update_marked_values(marked(("hash", HASH), ("version", "1")), (("version", "2"), ("hash", HASH)))

    def test_resource_parser_accepts_empty_and_selected_resources(self) -> None:
        with patch.object(sys, "argv", ["update-resource.py"]):
            self.assertEqual(UPDATER.parse_args().resources, [])
        with patch.object(sys, "argv", ["update-resource.py", "rtk", "qmd"]):
            self.assertEqual(UPDATER.parse_args().resources, ["rtk", "qmd"])
        with patch.object(sys, "argv", ["update-resource.py", "unknown"]):
            with self.assertRaises(SystemExit):
                UPDATER.parse_args()

    def test_argumentless_command_enumerates_every_resource_in_order(self) -> None:
        with patch.object(sys, "argv", ["update-resource.py"]), patch.object(UPDATER, "update_resource", return_value=0) as update_resource:
            self.assertEqual(UPDATER.main(), 0)
        self.assertEqual([call.args[0] for call in update_resource.call_args_list], list(UPDATER.RESOURCES))
        self.assertEqual(update_resource.call_args_list[0].args[0], "rtk")


if __name__ == "__main__":
    unittest.main()
