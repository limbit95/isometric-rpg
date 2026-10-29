# AI task contract

## Scope

- Repository: new isolated `isometric-rpg-step0` only.
- Godot pinned to 4.7.2; use typed GDScript when feasible.
- Never access or modify Unreal or another GitHub repository as a side effect.
- Prefer `.gd`, `.tscn`, `.tres` and validated assets over giant framework dependencies.

## Implementation protocol

1. Describe the task, touched files, and explicit acceptance criteria.
2. Work on `feature/<topic>`; do not push directly to a protected `main`.
3. Keep edits restricted to the current feature. Do not refactor unrelated systems.
4. Extend a test before merging a behavior change.
5. Execute Python tests, Godot headless import and runtime smoke, then play-test graphical changes.
6. Deliver PR with changed-file summary, passing checks, limitations and rollback steps.
7. User approves merge. No automatic production merges.

## Anti-patterns

- No speculative feature creation beyond the current STEP.
- No code-only 'works' claim if the engine test did not run.
- No new external dependencies or paid assets without documenting licenses.
- Do not store secrets in `.godot`, GDScript, CI files or docs.
