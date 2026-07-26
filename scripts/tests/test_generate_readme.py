from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


SCRIPT_PATH = Path(__file__).resolve().parents[1] / "generate-readme.py"
SPEC = importlib.util.spec_from_file_location("generate_readme", SCRIPT_PATH)
assert SPEC and SPEC.loader
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


def item(name: str, description: str, visibility: str = "public") -> dict[str, str]:
    return {
        "name": name,
        "description": description,
        "url": f"https://example.invalid/{name}",
        "visibility": visibility,
    }


def metadata() -> dict[str, list[dict[str, str]]]:
    return {
        "core": [item("beta", "Beta | description"), item("Alpha", "Alpha", "public"), item("Hidden", "Hidden", "private")],
        "agentic": [item("Agent", "Agent")],
        "devops": [item("DevOps", "DevOps")],
    }


def readme_fixture() -> str:
    return """manual prefix
<!-- BEGIN_GENERATED_CORE -->
old core
<!-- END_GENERATED_CORE -->
manual middle
<!-- BEGIN_GENERATED_AGENTIC -->
old agentic
<!-- END_GENERATED_AGENTIC -->
manual next
<!-- BEGIN_GENERATED_DEVOPS -->
old devops
<!-- END_GENERATED_DEVOPS -->
manual suffix
"""


class GenerateReadmeTest(unittest.TestCase):
    def test_render_tables_filters_private_items_and_sorts_names(self) -> None:
        table = GENERATOR.render_tables(metadata())["core"]

        self.assertEqual(
            table,
            "\n".join(
                (
                    "| Tool | Description |",
                    "| --- | --- |",
                    "| [Alpha](https://example.invalid/Alpha) | Alpha |",
                    "| [beta](https://example.invalid/beta) | Beta \\| description |",
                )
            ),
        )
        self.assertNotIn("Hidden", table)

    def test_replacement_preserves_all_manual_text(self) -> None:
        tables = {"core": "core table", "agentic": "agentic table", "devops": "devops table"}

        self.assertEqual(
            GENERATOR.replace_generated_sections(readme_fixture(), tables),
            """manual prefix
<!-- BEGIN_GENERATED_CORE -->
core table
<!-- END_GENERATED_CORE -->
manual middle
<!-- BEGIN_GENERATED_AGENTIC -->
agentic table
<!-- END_GENERATED_AGENTIC -->
manual next
<!-- BEGIN_GENERATED_DEVOPS -->
devops table
<!-- END_GENERATED_DEVOPS -->
manual suffix
""",
        )

    def test_rejects_missing_marker(self) -> None:
        with self.assertRaisesRegex(GENERATOR.GenerationError, "devops markers"):
            GENERATOR.replace_generated_sections(
                readme_fixture().replace("<!-- END_GENERATED_DEVOPS -->\n", ""),
                {"core": "core", "agentic": "agentic", "devops": "devops"},
            )

    def test_rejects_duplicated_marker(self) -> None:
        with self.assertRaisesRegex(GENERATOR.GenerationError, "core markers"):
            GENERATOR.replace_generated_sections(
                readme_fixture() + "<!-- BEGIN_GENERATED_CORE -->\n",
                {"core": "core", "agentic": "agentic", "devops": "devops"},
            )

    def test_rejects_reversed_markers(self) -> None:
        reversed_markers = """<!-- BEGIN_GENERATED_CORE -->
<!-- BEGIN_GENERATED_AGENTIC -->
<!-- END_GENERATED_CORE -->
<!-- END_GENERATED_AGENTIC -->
<!-- BEGIN_GENERATED_DEVOPS -->
<!-- END_GENERATED_DEVOPS -->
"""
        with self.assertRaisesRegex(GENERATOR.GenerationError, "wrong order"):
            GENERATOR.replace_generated_sections(
                reversed_markers,
                {"core": "core", "agentic": "agentic", "devops": "devops"},
            )

    def test_check_mode_rejects_stale_temporary_readme(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            repository_root = Path(temporary_directory)
            readme_path = repository_root / "README.md"
            original = readme_fixture()
            readme_path.write_text(original, encoding="utf-8")

            with patch.object(GENERATOR, "evaluate_metadata", return_value=metadata()):
                self.assertFalse(GENERATOR.generate_readme(repository_root, check=True))

            self.assertEqual(readme_path.read_text(encoding="utf-8"), original)


if __name__ == "__main__":
    unittest.main()
