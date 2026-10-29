"""Dependency-free STEP 1 structural checks; runtime behavior is in combat_smoke_runner.gd."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class CombatContractTests(unittest.TestCase):
    def test_required_combat_files(self):
        for path in (
            "scripts/player/player_attack.gd",
            "scripts/components/health_component.gd",
            "scripts/enemies/training_dummy.gd",
            "scenes/enemies/training_dummy.tscn",
            "tests/combat_smoke_runner.gd",
        ):
            with self.subTest(path=path):
                self.assertTrue((ROOT / path).is_file())

    def test_scene_external_resources_resolve(self):
        for name in ("scenes/main.tscn", "scenes/enemies/training_dummy.tscn"):
            content = (ROOT / name).read_text(encoding="utf-8")
            for path in re.findall(r'path="res://([^"]+)"', content):
                with self.subTest(scene=name, resource=path):
                    self.assertTrue((ROOT / path).is_file())

    def test_combat_components_are_separate(self):
        main_scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
        enemy_scene = (ROOT / "scenes/enemies/training_dummy.tscn").read_text(encoding="utf-8")
        attack = (ROOT / "scripts/player/player_attack.gd").read_text(encoding="utf-8")
        self.assertIn('[node name="Attack"', main_scene)
        self.assertIn('[node name="Hurtbox"', enemy_scene)
        self.assertIn("HURTBOX_MASK: int = 4", attack)
        self.assertIn("collide_with_areas = true", attack)
        self.assertIn('signal died', (ROOT / "scripts/components/health_component.gd").read_text(encoding="utf-8"))

    def test_existing_movement_not_replaced(self):
        movement = (ROOT / "scripts/player/player_controller.gd").read_text(encoding="utf-8")
        self.assertIn("Input.get_vector", movement)
        self.assertIn("move_and_slide", movement)


if __name__ == "__main__":
    unittest.main()
