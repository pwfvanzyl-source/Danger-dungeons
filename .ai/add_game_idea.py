#!/usr/bin/env python3
"""
add_game_idea.py

Usage:
  python .ai/add_game_idea.py --idea "A roguelike with magical traps"
  echo "A new idea text" | python .ai/add_game_idea.py

This script checks `.ai/game-description.md` for a similar idea. If none is found,
it appends a new "Idea" section to the file.
"""
import sys
import argparse
from pathlib import Path
from difflib import SequenceMatcher


def similar(a: str, b: str) -> float:
    return SequenceMatcher(None, a.lower(), b.lower()).ratio()


def load_game_description(path: Path) -> str:
    if not path.exists():
        path.write_text("# Danger Dungeons - Game Description\n\n")
    return path.read_text(encoding="utf-8")


def find_similar(existing_text: str, idea: str, threshold: float = 0.6) -> bool:
    # Check headings and lines for similarity
    lines = [l.strip() for l in existing_text.splitlines() if l.strip()]
    candidates = []
    for l in lines:
        if l.startswith('#') or l.startswith('-') or l.startswith('*') or l.startswith('##'):
            candidates.append(l.lstrip('#').lstrip('-').strip())
        else:
            candidates.append(l)
    for c in candidates:
        if not c:
            continue
        if idea.lower() in c.lower() or c.lower() in idea.lower():
            return True
        if similar(c, idea) >= threshold:
            return True
    return False


def append_idea(path: Path, idea: str):
    text = load_game_description(path)
    if find_similar(text, idea):
        print("A similar idea already exists in game-description.md. No changes made.")
        return
    # Create a short title
    title = idea.strip()
    if len(title) > 60:
        title = title[:57].rstrip() + "..."
    section = f"\n## Idea: {title}\n\n{idea.strip()}\n"
    path.write_text(text + section, encoding="utf-8")
    print(f"Added new idea to {path}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--idea', '-i', help='Idea text (optional; can read from stdin)')
    parser.add_argument('--file', '-f', default='.ai/game-description.md', help='Path to game description file')
    args = parser.parse_args()

    if args.idea:
        idea = args.idea
    else:
        if sys.stdin.isatty():
            print('Enter idea text (end with Ctrl+D):')
        idea = sys.stdin.read().strip()

    if not idea:
        print('No idea provided. Exiting.')
        return

    project_root = Path(__file__).resolve().parents[1]
    target = (project_root / args.file).resolve()
    append_idea(target, idea)


if __name__ == '__main__':
    main()
