#!/usr/bin/env python3
"""Generate paths-index.json from paths/*.yaml files.
Run from content repo root: python3 scripts/build-paths-index.py
"""
import json, sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml not installed.", file=sys.stderr); sys.exit(1)

root = Path(__file__).resolve().parent.parent
paths_dir = root / "paths"
challenges_index = json.loads((root / "challenges-index.json").read_text())
challenge_map = {c["dir_name"]: c for c in challenges_index}

entries = []
for p in sorted(paths_dir.glob("*.yaml")):
    data = yaml.safe_load(p.read_text())
    # Enrich challenge list with metadata
    enriched = []
    for name in data.get("challenges", []):
        ch = challenge_map.get(name)
        if ch:
            enriched.append({
                "dir_name": name,
                "name": ch["name"],
                "difficulty": ch["difficulty"],
                "category": ch["category"],
                "xp_reward": ch["xp_reward"],
                "time_estimate": ch["time_estimate"],
            })
    data["challenges"] = enriched
    data["total_challenges"] = len(enriched)
    data["total_xp"] = sum(c["xp_reward"] for c in enriched)
    entries.append(data)

out = root / "paths-index.json"
out.write_text(json.dumps(entries, indent=2, ensure_ascii=False) + "\n")
print(f"Wrote {out} ({len(entries)} paths)")
