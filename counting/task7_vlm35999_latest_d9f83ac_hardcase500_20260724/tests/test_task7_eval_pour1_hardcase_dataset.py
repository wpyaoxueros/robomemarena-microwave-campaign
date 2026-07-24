import base64
import importlib.util
import json
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).parents[1] / "tools" / "build_task7_eval_pour1_hardcase_dataset.py"
SPEC = importlib.util.spec_from_file_location("task7_eval_hardcase", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
assert SPEC and SPEC.loader
SPEC.loader.exec_module(MODULE)

PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAusB9Y9JdQAAAABJRU5ErkJggg=="
)


def template_row(label, image_count=10):
    return {
        "qid": "template_pour1",
        "images": ["old"] * image_count,
        "metadata": {"current_primitive": label},
        "messages": [
            {"role": "user", "content": "<image> " * image_count},
            {"role": "assistant", "content": json.dumps({"current_primitive": label, "keyframe_positions": []})},
        ],
    }


class Task7EvalHardcaseDatasetTest(unittest.TestCase):
    def test_builds_no_place_eval_hardcases_with_copied_images(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            episode = root / "episode"
            relative = []
            for index in range(10):
                rel = Path("vlm_inputs") / "t0455" / f"image_{index}.png"
                path = episode / rel
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(PNG)
                relative.append(str(rel))
            traces = [{"t": 455, "subtask": MODULE.PICK, "image": {"recent": relative}}]
            rows, audit = MODULE.build_dataset(
                [template_row(MODULE.PICK), template_row(MODULE.POUR_ONE)],
                traces,
                episode_root=episode,
                image_root=root / "images",
                duplicate_factor=3,
                source_run="run",
            )
            self.assertEqual(audit["augmented_rows"], 3)
            self.assertEqual(audit["place_rows"], 0)
            additions = rows[-3:]
            self.assertTrue(all(MODULE.primitive(row) == MODULE.POUR_ONE for row in additions))
            self.assertTrue(all(len(row["images"]) == 10 for row in additions))
            self.assertTrue(all(Path(path).is_file() for path in additions[0]["images"]))
            self.assertTrue(all(row["metadata"]["eval_source_timestep"] == 455 for row in additions))

    def test_rejects_first_pour_template_with_history_image_mismatch(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            traces = [{"t": 455, "subtask": MODULE.PICK, "image": {"recent": []}}]
            with self.assertRaisesRegex(ValueError, "runtime-aligned"):
                MODULE.build_dataset(
                    [template_row(MODULE.POUR_ONE, image_count=12)],
                    traces,
                    episode_root=root,
                    image_root=root / "images",
                    duplicate_factor=1,
                    source_run="run",
                )

    def test_rejects_trace_with_wrong_image_count(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            traces = [{"t": 455, "subtask": MODULE.PICK, "image": {"recent": []}}]
            with self.assertRaises(ValueError):
                MODULE.build_dataset(
                    [template_row(MODULE.POUR_ONE)],
                    traces,
                    episode_root=root,
                    image_root=root / "images",
                    duplicate_factor=1,
                    source_run="run",
                )


if __name__ == "__main__":
    unittest.main()
