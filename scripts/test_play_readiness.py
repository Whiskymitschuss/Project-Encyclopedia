"""Release audit regression checks with isolated source configurations."""
import importlib.util
import pathlib
import subprocess
import sys
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).with_name("play_readiness.py")
SPEC = importlib.util.spec_from_file_location("readiness", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)
ROOT = SCRIPT.parent.parent


class ReadinessTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="timber-release-")
        self.addCleanup(self.directory.cleanup)
        self.root = pathlib.Path(self.directory.name)
        for name in ("project.godot", "export_presets.cfg"):
            (self.root / name).write_bytes((ROOT / name).read_bytes())

    def change(self, before, after):
        path = self.root / "export_presets.cfg"
        text = path.read_text()
        self.assertIn(before, text)
        path.write_text(text.replace(before, after))

    def statuses(self):
        return {c["id"]: c["status"] for c in MODULE.audit(self.root)["checks"]}

    def test_test_apk_is_not_store_release(self):
        report = MODULE.audit(self.root)
        self.assertFalse(report["store_ready"])
        self.assertEqual(self.statuses()["aab_configuration"], "blocked")

    def test_aab_flag_does_not_prove_compatibility(self):
        self.change("gradle_build/use_gradle_build=false", "gradle_build/use_gradle_build=true")
        self.change("gradle_build/export_format=0", "gradle_build/export_format=1")
        statuses = self.statuses()
        self.assertEqual(statuses["aab_configuration"], "pass")
        self.assertEqual(statuses["android_compatibility"], "manual")
        self.assertFalse(MODULE.audit(self.root)["store_ready"])

    def test_new_permissions_require_review(self):
        self.change("permissions/internet=false", "permissions/internet=true")
        self.assertEqual(self.statuses()["android_0_offline_permissions"], "blocked")

    def test_version_mismatch_blocks(self):
        version = MODULE.audit(self.root)["version"]
        self.change(f'version/name="{version}"', 'version/name="other-build"')
        self.assertEqual(self.statuses()["android_0_version"], "blocked")

    def test_scope_and_architecture_regressions(self):
        self.change("releases/*,", "")
        self.change("architectures/arm64-v8a=true", "architectures/arm64-v8a=false")
        statuses = self.statuses()
        self.assertEqual(statuses["android_0_export_scope"], "blocked")
        self.assertEqual(statuses["android_0_arm64"], "blocked")

    def test_strict_cli_blocks_without_changing_sources(self):
        before = {p.name: p.read_bytes() for p in self.root.iterdir()}
        result = subprocess.run([sys.executable, str(SCRIPT), "--root", str(self.root), "--strict"], capture_output=True)
        self.assertEqual(result.returncode, 2)
        self.assertEqual(before, {p.name: p.read_bytes() for p in self.root.iterdir()})


if __name__ == "__main__":
    unittest.main()
