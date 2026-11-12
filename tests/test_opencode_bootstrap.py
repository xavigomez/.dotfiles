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

    @unittest.skipUnless(shutil.which("herdr"), "Herdr is required for integration checks")
    def test_herdr_preserves_preferences_links_and_single_registration(self):
        preferences = json.loads((ROOT / "opencode/.config/opencode/cli.json").read_text())
        # Exercise Herdr's config writer, not just its already-registered path.
        preferences["plugins"] = [p for p in preferences["plugins"] if p != "./herdr-opencode"]
        (self.source / "cli.json").write_text(json.dumps(preferences, indent=2) + "\n")
        self.stow()
        env = {
            **self.env,
            "XDG_CONFIG_HOME": str(self.home / ".config"),
            "XDG_STATE_HOME": str(self.home / ".local/state"),
            "XDG_DATA_HOME": str(self.home / ".local/share"),
            "XDG_CACHE_HOME": str(self.home / ".cache"),
        }
        for _ in range(2):
            result = subprocess.run(
                ["herdr", "integration", "install", "opencode"],
                env=env, cwd=self.home, capture_output=True, text=True, timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stderr)
            actual = json.loads((self.config / "cli.json").read_text())
            self.assertEqual(actual["plugins"], [*preferences["plugins"], "./herdr-opencode"])
            self.assertEqual(
                {k: v for k, v in actual.items() if k != "plugins"},
                {k: v for k, v in preferences.items() if k != "plugins"},
            )
            self.stow()
        self.assertTrue((self.config / "herdr-opencode/tui.js").is_file())
        self.assertEqual(sorted(p.name for p in self.source.iterdir()), ["cli.json", "opencode.jsonc"])
        status = subprocess.run(
            ["herdr", "integration", "status"],
            env=env, cwd=self.home, capture_output=True, text=True, timeout=30,
        )
        self.assertEqual(status.returncode, 0, status.stderr)
        self.assertRegex(status.stdout, r"(?m)^opencode: current")


class ConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.config = ROOT / "opencode/.config/opencode"
        self.cli = json.loads((self.config / "cli.json").read_text())

    def test_only_native_configuration_files_are_present(self):
        self.assertEqual(sorted(p.name for p in self.config.iterdir()), ["cli.json", "opencode.jsonc"])
        server = json.loads((self.config / "opencode.jsonc").read_text())
        self.assertEqual(server["$schema"], "https://opencode.ai/config.json")
        self.assertEqual(server["model"], "opencode-go/glm-5.2")
        self.assertEqual(server["providers"]["opencode-go"]["models"]["glm-5.2"]["settings"], {"reasoningEffort": "high"})

    def test_terminal_preferences_are_preserved(self):
        self.assertEqual(self.cli["$schema"], "https://opencode.ai/v2/cli.json")
        self.assertEqual(self.cli["theme"], {"name": "tokyonight"})
        self.assertEqual(self.cli["diffs"], {"wrap": "word"})
        self.assertEqual(self.cli["session"], {"sidebar": "auto", "scrollbar": False, "thinking": "show"})
        self.assertTrue(self.cli["animations"])
        self.assertNotIn("plugin", self.cli)

    def test_plugins_use_native_v2_entries(self):
        self.assertEqual(self.cli["plugins"], [
            {"package": "vimcode@git+https://github.com/oribarilan/vimcode.git#v0.19.2"},
            "./herdr-opencode",
        ])


if __name__ == "__main__":
    unittest.main()
