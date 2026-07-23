import os
import pathlib
import tempfile
import unittest

from openpi.training import config as openpi_config

from scripts.serve_policy_selfcontained import bind_checkpoint_assets


CONFIG_NAME = "pi05_libero_robomemarena_fullvlm_v2_noflip_dataset"
CHECKPOINT = pathlib.Path(os.environ.get("TASK6_VLA_CKPT", "/nonexistent/task6-vla-35999"))
ASSET_ID = "robomemarena_fullvlm_v2_noflip_dataset_v2"


class SelfContainedPolicyConfigTest(unittest.TestCase):
    @unittest.skipUnless(CHECKPOINT.is_dir(), "set TASK6_VLA_CKPT to run checkpoint integration test")
    def test_checkpoint_assets_take_priority_over_absolute_training_repo(self):
        original = openpi_config.get_config(CONFIG_NAME)
        self.assertTrue(pathlib.Path(original.data.repo_id).is_absolute())

        patched = bind_checkpoint_assets(original, CHECKPOINT)
        self.assertEqual(patched.data.assets.asset_id, ASSET_ID)
        self.assertEqual(patched.data.assets.assets_dir, str(CHECKPOINT / "assets"))

        norm_stats = patched.data._load_norm_stats(
            patched.assets_dirs,
            patched.data.repo_id,
            patched.data.assets.asset_id,
        )
        self.assertIsNotNone(norm_stats)

    def test_missing_checkpoint_norm_fails_closed(self):
        original = openpi_config.get_config(CONFIG_NAME)
        with tempfile.TemporaryDirectory() as temp_dir:
            with self.assertRaises(FileNotFoundError):
                bind_checkpoint_assets(original, pathlib.Path(temp_dir))


if __name__ == "__main__":
    unittest.main()
