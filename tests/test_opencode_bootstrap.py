"""Isolated OpenCode bootstrap checks: python3 -m unittest discover -s tests -v."""

import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "lib/opencode.sh"


class BootstrapTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles-opencode-")
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name) / "home with spaces"
        self.home.mkdir()
        self.dotfiles = self.home / ".dotfiles"
        self.source = self.dotfiles / "opencode/.config/opencode"
        self.source.mkdir(parents=True)
        for name in ("cli.json", "opencode.jsonc"):
            (self.source / name).write_text("{}\n")
        self.config = self.home / ".config/opencode"
        self.bin = Path(self.temp.name) / "bin"
        self.bin.mkdir()
        self.env = {
            **os.environ,
            "HOME": str(self.home),
            "PATH": f"{self.bin}:{os.environ['PATH']}",
        }

    def call(self, function, *args):
        return subprocess.run(
            ["/bin/bash", "-c", 'source "$1"; shift; "$@"', "test", str(HELPER), function, *map(str, args)],
            env=self.env,
            cwd=self.home,
            capture_output=True,
            text=True,
        )

    def fake_opencode(self, version, status=0):
        command = self.bin / "opencode"
        command.write_text(f"#!/bin/sh\nprintf '%s\\n' '{version}'\nexit {status}\n")
        command.chmod(0o755)

    def test_accepts_v2_version_formats(self):
        for version in ("opencode v2.2.6", "2.2.6", "v2.2.6", "opencode v2.2.6-dev.1"):
            with self.subTest(version=version):
                self.fake_opencode(version)
                self.assertEqual(self.call("opencode_require_v2").returncode, 0)

    def test_rejects_v1_future_and_invalid_versions(self):
        for version in ("1.17.20", "opencode v1.17.20", "opencode v3.0.0", "2.2", "invalid", ""):
            with self.subTest(version=version):
                self.fake_opencode(version)
                result = self.call("opencode_require_v2")
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("OpenCode V2 is required", result.stderr)

    def test_rejects_failed_version_command(self):
        self.fake_opencode("opencode v2.2.6", status=1)
        result = self.call("opencode_require_v2")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("could not run", result.stderr)

    def stow(self):
        if not shutil.which("stow"):
            self.skipTest("GNU Stow is required")
        result = self.call("opencode_stow", self.dotfiles)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.config.is_dir())
        self.assertFalse(self.config.is_symlink())
        for name in ("cli.json", "opencode.jsonc"):
            self.assertTrue((self.config / name).is_symlink())
            self.assertEqual((self.config / name).resolve(), self.source / name)

    def test_fresh_home_keeps_runtime_outside_repository(self):
        self.stow()
        (self.config / "service.json").write_text("local-only\n")
        (self.config / "herdr-opencode").mkdir()
        (self.config / "herdr-opencode/tui.js").write_text("// managed\n")
        self.assertEqual(sorted(p.name for p in self.source.iterdir()), ["cli.json", "opencode.jsonc"])

    def test_repeat_run_preserves_state_preferences_and_links(self):
        self.stow()
        preferences = {"theme": {"name": "tokyonight"}, "session": {"thinking": "show"}}
        (self.config / "cli.json").write_text(json.dumps(preferences))
        (self.config / "service.json").write_text("local-only\n")
        self.stow()
        self.assertEqual(json.loads((self.config / "cli.json").read_text()), preferences)
        self.assertEqual((self.config / "service.json").read_text(), "local-only\n")

    def test_unfolds_existing_package_directory_link(self):
        self.config.parent.mkdir()
        self.config.symlink_to(os.path.relpath(self.source, self.config.parent), target_is_directory=True)
        self.stow()
        (self.config / "service.json").write_text("local-only\n")
        self.assertFalse((self.source / "service.json").exists())

    def test_unfolds_config_parent_from_another_stow_package(self):
        other = self.dotfiles / "other/.config"
        other.mkdir(parents=True)
        (other / "other.conf").write_text("keep\n")
        self.config.parent.symlink_to(os.path.relpath(other, self.home), target_is_directory=True)
        self.stow()
        self.assertFalse(self.config.parent.is_symlink())
        self.assertEqual((self.config.parent / "other.conf").resolve(), other / "other.conf")

    def test_conflicting_local_config_is_not_adopted(self):
        self.config.mkdir(parents=True)
        path = self.config / "cli.json"
        path.write_text("local preferences\n")
        result = self.call("opencode_stow", self.dotfiles)
        if not shutil.which("stow"):
            self.skipTest("GNU Stow is required")
        self.assertNotEqual(result.returncode, 0)
        self.assertFalse(path.is_symlink())
        self.assertEqual(path.read_text(), "local preferences\n")
        self.assertEqual((self.source / "cli.json").read_text(), "{}\n")

    def test_unowned_directory_link_is_not_replaced(self):
        if not shutil.which("stow"):
            self.skipTest("GNU Stow is required")
        elsewhere = self.home / "other-config"
        elsewhere.mkdir()
        (elsewhere / "cli.json").write_text("local preferences\n")
        self.config.parent.mkdir()
        self.config.symlink_to(elsewhere, target_is_directory=True)
        result = self.call("opencode_stow", self.dotfiles)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.config.resolve(), elsewhere)
        self.assertEqual((elsewhere / "cli.json").read_text(), "local preferences\n")


if __name__ == "__main__":
    unittest.main()
