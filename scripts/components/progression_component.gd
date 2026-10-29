class_name ProgressionComponent
extends Node
## Lifetime XP within the current level, one-time level-up events.

signal experience_changed(level: int, experience: int, required: int)
signal leveled_up(new_level: int)

@export_range(1, 99, 1) var max_level: int = 10
var level: int = 1
var experience: int = 0


func required_experience() -> int:
    return 10 + (level - 1) * 5


func add_experience(amount: int) -> bool:
    if amount <= 0 or level >= max_level:
        return false
    experience += amount
    while level < max_level and experience >= required_experience():
        experience -= required_experience()
        level += 1
        leveled_up.emit(level)
    if level == max_level:
        experience = 0
    experience_changed.emit(level, experience, required_experience())
    return true
