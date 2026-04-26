#!/usr/bin/env python3
"""Generate challenges-index.json from all challenges/*/challenge.yaml files.
Run from content repo root: python3 scripts/build-index.py
"""
import json, sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: pyyaml not installed. Run: pip install pyyaml", file=sys.stderr)
    sys.exit(1)

root = Path(__file__).resolve().parent.parent
challenges_dir = root / "challenges"

KEY_ORDER = ["dir_name","name","type","category","difficulty","tags",
             "time_estimate","xp_reward","packages","pre_install","namespace",
             "files","setup","instructions","hints","validation"]

entries = []
for ch_dir in sorted(challenges_dir.iterdir()):
    if not ch_dir.is_dir(): continue
    yml = ch_dir / "challenge.yaml"
    if not yml.is_file(): continue
    try:
        data = yaml.safe_load(yml.read_text())
    except yaml.YAMLError as e:
        print(f"ERROR parsing {yml}: {e}", file=sys.stderr); sys.exit(1)
    if not isinstance(data, dict): continue
    data["dir_name"] = ch_dir.name
    ordered = {k: data[k] for k in KEY_ORDER if k in data}
    for k, v in data.items():
        if k not in ordered: ordered[k] = v
    entries.append(ordered)

out = root / "challenges-index.json"
out.write_text(json.dumps(entries, indent=2, ensure_ascii=False) + "\n")
print(f"Wrote {out} ({len(entries)} challenges)")
