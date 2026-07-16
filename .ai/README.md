# AI workspace instructions

This folder is reserved for workspace-specific guidance for AI assistants.

Always read this folder first when working in this project.

Project context:
- Project name: danger-dungeons
- Engine: Godot
- Keep game development work organized and focused on the game project.

Utilities:
- `add_game_idea.py`: Script to check and append new game ideas to `game-description.md`.

Usage:
 - Run with an idea argument:
	 `python .ai/add_game_idea.py --idea "A turn-based dungeon crawler with traps"`
 - Or pipe text into it:
	 `echo "A new idea" | python .ai/add_game_idea.py`

Behavior for assistants:
- When the user states a new game idea, check `game-description.md`. If a similar idea
	isn't already present, run the script to append it.
