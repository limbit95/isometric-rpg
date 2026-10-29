"""Dependency-free structural smoke checks (not a substitute for Godot runtime tests)."""
from pathlib import Path
import struct
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ProjectContractTests(unittest.TestCase):
    def test_required_files(self):
        required = (
            "project.godot", "scenes/main.tscn",
            "scripts/game/main.gd", "scripts/world/isometric_world.gd",
            "scripts/player/player_controller.gd", "tests/smoke_runner.gd",
            "assets/tiles/isometric_ground.png",
            "assets/characters/player_placeholder.png",
            ".github/workflows/verify.yml",
        )
        for name in required:
            with self.subTest(path=name):
                self.assertTrue((ROOT / name).is_file())

    def test_scene_references_existing_files(self):
        source = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
        for file_ref in re.findall(r'path="res://([^"]+)"', source):
            with self.subTest(file_ref=file_ref):
                self.assertTrue((ROOT / file_ref).exists())

    def test_movement_actions(self):
        source = (ROOT / "scripts/game/main.gd").read_text(encoding="utf-8")
        for name in ("move_left", "move_right", "move_up", "move_down"):
            self.assertIn(f'"{name}"', source)

    def test_tilemap_dimensions(self):
        source = (ROOT / "scripts/world/isometric_world.gd").read_text(encoding="utf-8")
        self.assertIn("Vector2i(64, 32)", source)
        self.assertIn("TILE_SHAPE_ISOMETRIC", source)
        self.assertIn("extends TileMapLayer", source)

    def test_atlas_dimensions(self):
        raw = (ROOT / "assets/tiles/isometric_ground.png").read_bytes()
        self.assertEqual(raw[:8], b"\x89PNG\r\n\x1a\n")
        self.assertEqual(struct.unpack(">II", raw[16:24]), (128, 32))

    def test_main_scene_set(self):
        config = (ROOT / "project.godot").read_text(encoding="utf-8")
        self.assertIn('run/main_scene="res://scenes/main.tscn"', config)


if __name__ == "__main__":
    unittest.main()
