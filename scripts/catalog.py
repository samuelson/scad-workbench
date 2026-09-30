#!/usr/bin/env python3
"""Build models/catalog.json from every .scad file in models/."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODELS_DIR = ROOT / "models"
OUTPUT = MODELS_DIR / "catalog.json"


def humanize(stem: str) -> str:
    label = stem.replace("-", " ").replace("_", " ").strip()
    if not label:
        return stem
    return label[0].upper() + label[1:]


def metadata(path: Path) -> tuple[str | None, str | None, list[str]]:
    name = None
    description = None
    comments: list[str] = []
    text = path.read_text(encoding="utf-8")
    for raw in text.splitlines():
        line = raw.strip()
        if line.startswith("//"):
            body = line[2:].strip()
            if not body:
                continue
            key, _, value = body.partition(":")
            lowered = key.strip().lower()
            if lowered == "name" and value.strip():
                name = value.strip()
            elif lowered == "description" and value.strip():
                description = value.strip()
            else:
                comments.append(body)
        elif line:
            break
    return name, description, comments


def entry(path: Path) -> dict[str, str]:
    meta_name, meta_description, comments = metadata(path)
    return {
        "name": meta_name or humanize(path.stem),
        "description": meta_description or (comments[0] if comments else ""),
        "path": f"./models/{path.name}",
    }


def main() -> None:
    MODELS_DIR.mkdir(parents=True, exist_ok=True)
    models = [entry(path) for path in sorted(MODELS_DIR.glob("*.scad"))]
    OUTPUT.write_text(json.dumps(models, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"wrote {OUTPUT.relative_to(ROOT)} ({len(models)} model{'s' if len(models) != 1 else ''})")


if __name__ == "__main__":
    main()
