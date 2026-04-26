#!/usr/bin/env python3
"""
Fix silent-failure patterns in validate.sh:
1. Bare ansible-playbook --syntax-check → wrapped with if !/FAIL
2. Bare terraform init/validate → wrapped with if !/FAIL
3. Bare grep -q lines → wrapped with if !/FAIL
"""
import re
from pathlib import Path

root = Path(__file__).resolve().parent.parent / "challenges"
fixed_files = []

# Patterns to replace: (regex, replacement_template)
# Each replacement uses \1 for the captured command
TRANSFORMS = [
    # ansible-playbook --syntax-check (bare)
    (
        re.compile(r'^(ansible-playbook[^\n]+--syntax-check[^\n]*)\n', re.MULTILINE),
        'if ! \\1; then\n  echo "FAIL: Playbook has syntax errors"\n  exit 1\nfi\n'
    ),
    # terraform init (bare)
    (
        re.compile(r'^(terraform init[^\n]*)\n', re.MULTILINE),
        'if ! \\1; then\n  echo "FAIL: terraform init failed"\n  exit 1\nfi\n'
    ),
    # terraform validate (bare)
    (
        re.compile(r'^(terraform validate[^\n]*)\n', re.MULTILINE),
        'if ! \\1; then\n  echo "FAIL: terraform validate failed — check your HCL syntax"\n  exit 1\nfi\n'
    ),
    # bare grep -q 'pattern' file (not already inside if/||)
    (
        re.compile(r'^(grep -q [^\n]+)\n', re.MULTILINE),
        lambda m: (
            'if ! ' + m.group(1) + '; then\n'
            '  echo "FAIL: Expected pattern not found: ' + m.group(1).split("'")[1] if "'" in m.group(1) else m.group(1)[8:40] + '..."\n'
            '  exit 1\nfi\n'
        ) if not m.group(1).startswith('grep -q \'?\'') else m.group(0)
    ),
]

# Simpler targeted grep-q fix using line-by-line approach
def fix_bare_grep(content: str) -> str:
    lines = content.split('\n')
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        # Bare grep -q not inside if/while/for and not already wrapped
        if (stripped.startswith('grep -q ') and
                not stripped.startswith('if ') and
                not stripped.endswith('|| {') and
                '||' not in stripped and
                '&&' not in stripped):
            # Extract what we're looking for for the error message
            m = re.search(r"grep -q '([^']+)'", stripped)
            pattern_desc = m.group(1)[:50] if m else stripped[8:50]
            out.append(f'if ! {stripped}; then')
            out.append(f'  echo "FAIL: Expected to find: {pattern_desc}"')
            out.append('  exit 1')
            out.append('fi')
        else:
            out.append(line)
        i += 1
    return '\n'.join(out)

def fix_bare_ansible_syntax(content: str) -> str:
    lines = content.split('\n')
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if (stripped.startswith('ansible-playbook ') and
                '--syntax-check' in stripped and
                not stripped.startswith('if ') and
                '||' not in stripped and
                '&&' not in stripped):
            out.append(f'if ! {stripped}; then')
            out.append('  echo "FAIL: Playbook has syntax errors — run ansible-playbook --syntax-check to see details"')
            out.append('  exit 1')
            out.append('fi')
        else:
            out.append(line)
        i += 1
    return '\n'.join(out)

def fix_bare_terraform(content: str) -> str:
    lines = content.split('\n')
    out = []
    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()
        if (re.match(r'^terraform (init|validate)\b', stripped) and
                not stripped.startswith('if ') and
                '||' not in stripped and
                '&&' not in stripped):
            cmd_word = re.match(r'^terraform (\w+)', stripped).group(1)
            msg = {
                'init': 'FAIL: terraform init failed — check provider configuration',
                'validate': 'FAIL: terraform validate failed — check your HCL syntax',
            }.get(cmd_word, f'FAIL: terraform {cmd_word} failed')
            out.append(f'if ! {stripped}; then')
            out.append(f'  echo "{msg}"')
            out.append('  exit 1')
            out.append('fi')
        else:
            out.append(line)
        i += 1
    return '\n'.join(out)

for ch_dir in sorted(root.iterdir()):
    if not ch_dir.is_dir():
        continue
    vs = ch_dir / "validate.sh"
    if not vs.is_file():
        continue

    original = vs.read_text()
    fixed = original
    fixed = fix_bare_ansible_syntax(fixed)
    fixed = fix_bare_terraform(fixed)
    fixed = fix_bare_grep(fixed)

    if fixed != original:
        vs.write_text(fixed)
        fixed_files.append(ch_dir.name)

print(f"Fixed {len(fixed_files)} validate.sh files:")
for f in fixed_files:
    print(f"  {f}")
