"""STEP 3 Python source contracts; Godot test checks runtime behavior."""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SkillsContractTests(unittest.TestCase):
    def test_required_source_files(self):
        for path in ("scripts/components/mana_component.gd",
                     "scripts/player/player_skills.gd",
                     "scripts/skills/skill_projectile.gd",
                     "tests/skills_smoke_runner.gd"):
            with self.subTest(path=path):
                self.assertTrue((ROOT / path).is_file())

    def test_scene_wiring(self):
        content = (ROOT / "scenes/main.tscn").read_text(encoding="utf-8")
        self.assertIn('[node name="ManaComponent" type="Node" parent="Player"]', content)
        self.assertIn('[node name="Skills" type="Node2D" parent="Player"]', content)
        self.assertIn('[node name="PlayerMana"', content)
        self.assertIn('[node name="SkillStatus"', content)

    def test_skills_not_mixed_with_original_attack(self):
        attack = (ROOT / "scripts/player/player_attack.gd").read_text(encoding="utf-8")
        skills = (ROOT / "scripts/player/player_skills.gd").read_text(encoding="utf-8")
        self.assertIn("func queue_attack_at", attack)
        self.assertIn("func cast_cone_at", skills)
        self.assertIn("func cast_bolt_at", skills)
        self.assertIn("cone_cooldown_remaining", skills)
        self.assertIn("bolt_cooldown_remaining", skills)
        self.assertIn("mana.try_spend", skills)

    def test_input_and_verification(self):
        game = (ROOT / "scripts/game/main.gd").read_text(encoding="utf-8")
        runner = (ROOT / "tools/verify.sh").read_text(encoding="utf-8")
        self.assertIn('"skill_cone": [KEY_Q]', game)
        self.assertIn('"skill_bolt": [KEY_E]', game)
        self.assertIn('skills_smoke_runner.gd', runner)


if __name__ == "__main__":
    unittest.main()
