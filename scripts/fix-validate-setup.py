#!/usr/bin/env python3
"""
Fix two classes of bugs across all challenges:

1. validate.sh: remove `set -e` (causes silent exit before FAIL messages print)
2. setup.sh: convert non-sudo writes to /etc/ into sudo tee equivalents
"""
import re
import sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent / "challenges"
validate_fixed = []
setup_fixed = []

for ch_dir in sorted(root.iterdir()):
    if not ch_dir.is_dir():
        continue

    # ── Fix 1: validate.sh ──────────────────────────────────────────────────
    vs = ch_dir / "validate.sh"
    if vs.is_file():
        original = vs.read_text()
        # Remove bare `set -e` lines (keep set +e if already present)
        fixed = re.sub(r'^set -e\n', '', original, flags=re.MULTILINE)
        # Also fix the broken pattern: `CMD 2>/dev/null\nif [ $? -ne 0 ]`
        # → `if ! CMD 2>/dev/null`
        fixed = re.sub(
            r'(kubectl apply[^\n]+2>/dev/null)\nif \[ \$\? -ne 0 \]; then',
            r'if ! \1; then',
            fixed
        )
        if fixed != original:
            vs.write_text(fixed)
            validate_fixed.append(ch_dir.name)

    # ── Fix 2: setup.sh /etc/ writes ────────────────────────────────────────
    sh = ch_dir / "files" / "setup.sh"
    if sh.is_file():
        original = sh.read_text()
        fixed = original

        # cat > /etc/... <<'EOF'  →  sudo tee /etc/... <<'EOF' > /dev/null
        fixed = re.sub(
            r'\bcat\s*>\s*(/etc/\S+)\s*(<<[\'"]?\w+[\'"]?)',
            r'sudo tee \1 \2 > /dev/null',
            fixed
        )

        # echo "..." > /etc/...  →  echo "..." | sudo tee /etc/... > /dev/null
        fixed = re.sub(
            r'(echo\s+[^\n]+?)\s*>\s*(/etc/\S+)',
            r'\1 | sudo tee \2 > /dev/null',
            fixed
        )

        # echo "..." >> /etc/...  →  echo "..." | sudo tee -a /etc/... > /dev/null
        fixed = re.sub(
            r'(echo\s+[^\n]+?)\s*>>\s*(/etc/\S+)',
            r'\1 | sudo tee -a \2 > /dev/null',
            fixed
        )

        # tee /etc/...  (already has input piped, just add sudo)
        fixed = re.sub(
            r'(?<!sudo )\btee\s+(/etc/\S+)',
            r'sudo tee \1',
            fixed
        )

        if fixed != original:
            sh.write_text(fixed)
            setup_fixed.append(ch_dir.name)

print(f"validate.sh fixed ({len(validate_fixed)}):")
for n in validate_fixed:
    print(f"  {n}")

print(f"\nsetup.sh fixed ({len(setup_fixed)}):")
for n in setup_fixed:
    print(f"  {n}")
