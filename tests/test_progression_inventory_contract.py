"""STEP4 source contracts. Real gameplay is verified in the Godot smoke."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ProgressionInventoryContractTests(unittest.TestCase):
    def test_required_files(self):
        paths = (
            "scripts/components/progression_component.gd",
            "scripts/components/inventory_component.gd",
            "scripts/items/item_data.gd",
            "scripts/items/item_catalog.gd",
            "scripts/items/world_pickup.gd",
            "scenes/items/world_pickup.tscn",
            "data/items/iron_shard.tres",
            "data/items/training_blade.tres",
            "data/items/focus_charm.tres",
            "tests/progression_inventory_smoke_runner.gd",
        )
        for name in paths:
            with self.subTest(path=name):
                self.assertTrue((ROOT / name).is_file())

    def test_resources_references_resolve(self):
        for name in ("scenes/main.tscn", "scenes/items/world_pickup.tscn",
                     "data/items/iron_shard.tres", "data/items/training_blade.tres", "data/items/focus_charm.tres"):
            content = (ROOT / name).read_text(encoding="utf-8")
            for path in re.findall(r'path="res://([^"]+)"', content):
                with self.subTest(scene=name, resource=path):
                    self.assertTrue((ROOT / path).is_file())

    def test_component_contracts(self):
        main = (ROOT / "scripts/game/main.gd").read_text(encoding="utf-8")
        attack = (ROOT / "scripts/player/player_attack.gd").read_text(encoding="utf-8")
        inv = (ROOT / "scripts/components/inventory_component.gd").read_text(encoding="utf-8")
        self.assertIn("progression.add_experience(5)", main)
        self.assertIn("_spawn_pickup", main)
        self.assertIn("get_attack_bonus", attack)
        self.assertIn("func equip_item", inv)
        self.assertIn("max_slots", inv)

    def test_verification_runner(self):
        sh = (ROOT / "tools/verify.sh").read_text(encoding="utf-8")
        self.assertIn("progression_inventory_smoke_runner.gd", sh)


if __name__ == "__main__":
    unittest.main()
