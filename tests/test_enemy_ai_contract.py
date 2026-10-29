"""STEP 2 static contract checks. Runtime behavior is tested in Godot."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class EnemyAIContractTests(unittest.TestCase):
    def test_new_files_exist(self):
        paths = (
            "scripts/enemies/chaser_enemy.gd",
            "scenes/enemies/chaser_enemy.tscn",
            "tests/enemy_ai_smoke_runner.gd",
        )
        for name in paths:
            with self.subTest(name=name):
                self.assertTrue((ROOT / name).is_file())

    def test_enemy_state_machine(self):
        script = (ROOT / "scripts/enemies/chaser_enemy.gd").read_text(encoding="utf-8")
        for token in ("IDLE", "CHASE", "WINDUP", "RECOVER", "RETURN", "DEAD",
                      "leash_radius", "detection_radius", "_target_alive",
                      "attack_cooldown", "move_and_slide", "set_home_position"):
            with self.subTest(token=token):
                self.assertIn(token, script)

    def test_player_health_attached(self):
        scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
        self.assertIn('[node name="HealthComponent" type="Node" parent="Player"]', scene)
        self.assertIn('[node name="PlayerHealth"', scene)
        player = (ROOT / "scripts/player/player_controller.gd").read_text(encoding="utf-8")
        self.assertIn("health.is_dead()", player)

    def test_original_step1_content_preserved(self):
        scene = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
        main = (ROOT / "scripts/game/main.gd").read_text(encoding="utf-8")
        self.assertIn('[node name="Attack"', scene)
        self.assertIn("TRAINING_DUMMY_SCENE", main)
        self.assertIn("CHASER_SCENE", main)


if __name__ == "__main__":
    unittest.main()
