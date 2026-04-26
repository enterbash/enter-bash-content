#!/usr/bin/env python3
"""
Generate solution.md for all 165 challenges by parsing validate.sh directly.
Each solution is derived from the actual FAIL conditions in validate.sh,
so it precisely addresses what the validator checks.

Run from content repo root: python3 scripts/generate-solutions.py
"""
import re, yaml
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHALLENGES = ROOT / "challenges"

def read(p):
    try: return Path(p).read_text()
    except: return ""

def parse_checks(validate_sh: str) -> list[dict]:
    """
    Extract (condition, fail_message, comment) triples from validate.sh.
    Returns list of dicts with keys: fail_msg, condition, comment
    """
    checks = []
    lines = validate_sh.split('\n')
    pending_comment = ''
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        # Accumulate comments above a check
        if line.startswith('#') and not line.startswith('#!'):
            pending_comment = line.lstrip('#').strip()
            i += 1
            continue
        # Pattern: if [ ! -f ... ] or if ! cmd ...; then
        if line.startswith('if ') and i + 1 < len(lines):
            # Collect the full if block
            block_lines = [line]
            j = i + 1
            while j < len(lines) and not lines[j].strip().startswith('fi'):
                block_lines.append(lines[j].strip())
                j += 1
            block = '\n'.join(block_lines)
            # Extract FAIL message — use greedy match up to last " on the line
            fail_match = re.search(r'echo "FAIL: (.+?)"(?:\s*$|\s*;)', block, re.MULTILINE)
            if not fail_match:
                fail_match = re.search(r"echo \"FAIL: (.+)\"", block)
            if fail_match:
                # Clean up regex escape artifacts and shell variable references
                msg = fail_match.group(1)
                msg = msg.replace('\\.', '.').replace('\\*', '*').replace('\\"', '"')
                # Replace shell variables with readable placeholders
                msg = re.sub(r'\$\{?\w+\}?', '<value>', msg)
                checks.append({
                    'fail_msg': msg,
                    'condition': line,
                    'comment': pending_comment,
                    'block': block,
                })
            pending_comment = ''
            i = j + 1
            continue
        # Pattern: [ -f file ] || { echo "FAIL..." }
        if '|| {' in line or "|| { echo" in line:
            fail_match = re.search(r'echo "FAIL: (.+?)"', line)
            if fail_match:
                msg = fail_match.group(1).replace('\\.', '.').replace('\\*', '*')
                checks.append({
                    'fail_msg': msg,
                    'condition': line,
                    'comment': pending_comment,
                    'block': line,
                })
            pending_comment = ''
        else:
            if not line.startswith('#'):
                pending_comment = ''
        i += 1
    return checks

def extract_files_needed(checks: list[dict]) -> list[str]:
    """Extract file paths that must exist from FAIL conditions."""
    files = []
    for c in checks:
        # [ ! -f /path ] or [ ! -x /path ]
        m = re.search(r'\[ [!-][fx] ([^\]]+)\]', c['condition'])
        if m:
            files.append(m.group(1).strip())
        # FAIL message mentions a path
        m = re.search(r'(~/\S+|/home/runner/\S+|/tmp/\S+)', c['fail_msg'])
        if m:
            p = m.group(1).rstrip('.')
            if p not in files:
                files.append(p)
    return list(dict.fromkeys(files))  # deduplicate preserving order

def extract_grep_patterns(checks: list[dict]) -> list[tuple[str, str]]:
    """Extract (pattern, file) pairs from grep -q checks."""
    patterns = []
    for c in checks:
        # grep -q 'pattern' file or grep -qi 'pattern' file
        m = re.search(r"grep -qi? '([^']+)' ([^\s;]+)", c['block'])
        if m:
            patterns.append((m.group(1), m.group(2), c['fail_msg']))
        # grep -qE 'pattern' file
        m = re.search(r"grep -qE '([^']+)' ([^\s;]+)", c['block'])
        if m:
            patterns.append((m.group(1), m.group(2), c['fail_msg']))
    return patterns

def generate_solution(ch_dir: Path) -> str:
    name = ch_dir.name
    cy_path = ch_dir / "challenge.yaml"
    vs_path = ch_dir / "validate.sh"
    if not cy_path.is_file() or not vs_path.is_file():
        return ""

    data = yaml.safe_load(cy_path.read_text())
    validate_sh = vs_path.read_text()
    category = data.get('category', '')
    title = data.get('name', name)
    checks = parse_checks(validate_sh)

    # Read starter files for context
    starter_files = {}
    files_dir = ch_dir / "files"
    if files_dir.is_dir():
        for f in files_dir.iterdir():
            if f.suffix in ('.yml', '.yaml', '.tf', '.sh', '.ini', '.j2', '.txt', '.conf', '.md'):
                starter_files[f.name] = f.read_text()

    lines = [f"# Solution: {title}\n"]

    # Build solution based on category + validate.sh checks
    if category == 'linux':
        lines.append(generate_linux(name, data, checks, validate_sh, starter_files))
    elif category == 'ansible':
        lines.append(generate_ansible(name, data, checks, validate_sh, starter_files))
    elif category == 'docker':
        lines.append(generate_docker(name, data, checks, validate_sh, starter_files))
    elif category == 'kubernetes':
        lines.append(generate_k8s(name, data, checks, validate_sh, starter_files))
    elif category == 'terraform':
        lines.append(generate_terraform(name, data, checks, validate_sh, starter_files))
    else:
        lines.append(generate_generic(name, data, checks, validate_sh))

    return '\n'.join(lines) + '\n'


# ── Linux ──────────────────────────────────────────────────────────────────

def generate_linux(name, data, checks, validate_sh, starter_files):
    title = data.get('name', name)
    out = ["## What the validator checks\n"]

    # List every FAIL condition as a requirement
    for c in checks:
        if c['comment']:
            out.append(f"- **{c['comment']}**: {c['fail_msg']}")
        else:
            out.append(f"- {c['fail_msg']}")

    out.append("\n## Solution\n")

    # Build solution from checks
    solution_cmds = []
    notes = []

    for c in checks:
        fail = c['fail_msg']
        block = c['block']

        # File must exist
        m = re.search(r'\[ [!-]f ([^\]]+)\]', block)
        if m and 'not found' in fail.lower():
            path = m.group(1).strip()
            solution_cmds.append(f"# Create {path} if it doesn't exist")
            continue

        # File must be executable
        if '! -x' in block or 'not executable' in fail.lower():
            m = re.search(r'\[ [!-]x ([^\]]+)\]', block)
            if m:
                path = m.group(1).strip()
                solution_cmds.append(f"chmod +x {path}")
            continue

        # Crontab check
        if 'crontab' in fail.lower() or 'cron' in fail.lower():
            m = re.search(r"grep -qE '([^']+)'", block)
            if m:
                pattern = m.group(1)
                # Extract the cron expression from the pattern
                cron_match = re.search(r'\^([\d\s\*]+)', pattern)
                if cron_match:
                    cron = cron_match.group(1).strip()
                    solution_cmds.append(f'(crontab -l 2>/dev/null; echo "{cron} /home/runner/backup.sh") | crontab -')
            continue

        # Permission checks
        if 'should be' in fail and ('700' in fail or '600' in fail or '644' in fail or '755' in fail):
            m = re.search(r'(\S+) should be (\d+)', fail)
            if m:
                path_hint = m.group(1)
                perm = m.group(2)
                solution_cmds.append(f"chmod {perm} ~/{path_hint.lstrip('~/')}")
            continue

        # grep content checks — what must be in a file
        m = re.search(r"grep -qi? '([^']+)' ([^\s;]+)", block)
        if m:
            pattern = m.group(1)
            target_file = m.group(2)
            notes.append(f"- `{target_file}` must contain text matching `{pattern}`")
            continue

        # grep -qE pattern
        m = re.search(r"grep -qE '([^']+)' ([^\s;]+)", block)
        if m:
            pattern = m.group(1)
            target_file = m.group(2)
            notes.append(f"- `{target_file}` must match pattern `{pattern}`")
            continue

    # Emit the solution based on challenge name patterns
    if 'analyze' in name and 'log' in name:
        out.append("""```bash
# Count log levels
ERROR_COUNT=$(grep -c 'ERROR' /var/log/webapp/app.log)
WARN_COUNT=$(grep -c 'WARN' /var/log/webapp/app.log)
INFO_COUNT=$(grep -c 'INFO' /var/log/webapp/app.log)

# Find most common error message
COMMON_ERROR=$(grep 'ERROR' /var/log/webapp/app.log \\
  | sort | uniq -c | sort -rn | head -1 \\
  | sed 's/^ *[0-9]* *//')

# Write the report (must contain "ERROR", a count, and "database"/"connection"/"timeout")
cat > /home/runner/log-analysis.txt << EOF
ERROR count: $ERROR_COUNT
WARN count: $WARN_COUNT
INFO count: $INFO_COUNT
Most common error: $COMMON_ERROR
EOF
```

The validator checks that `/home/runner/log-analysis.txt`:
1. Exists and is non-empty
2. Contains the word `ERROR`
3. Contains at least one number
4. Contains `database`, `connection`, or `timeout` (the most common error in the log)""")

    elif 'crontab' in name:
        out.append("""```bash
# 1. Make the backup script executable
chmod +x /home/runner/backup.sh

# 2. Add the cron entry — runs at 2:00 AM every day
(crontab -l 2>/dev/null; echo "0 2 * * * /home/runner/backup.sh") | crontab -

# 3. Verify
crontab -l

# 4. Run it once to confirm it creates the backup file
bash /home/runner/backup.sh
ls /home/runner/backups/
```

The cron expression `0 2 * * *` means: minute=0, hour=2, every day. The validator checks for `^0 2 * * *` at the start of the crontab line.""")

    elif 'compress' in name or 'archive' in name:
        out.append("""```bash
# Create a gzip-compressed tar archive of the webapp directory
tar -czf /home/runner/webapp-backup.tar.gz -C /home/runner webapp/

# Verify the archive contains the expected files
tar -tzf /home/runner/webapp-backup.tar.gz
```

`-c` = create, `-z` = gzip compress, `-f` = output file. `-C /home/runner` changes to that directory first so paths inside the archive are relative.""")

    elif 'symlink' in name:
        out.append("""```bash
# Check which symlinks are broken
ls -la /home/runner/myapp/

# Fix each broken symlink to point to current/ instead of old/
ln -sf /home/runner/myapp/current/config.env  /home/runner/myapp/config.env
ln -sf /home/runner/myapp/current/start.sh    /home/runner/myapp/start.sh
ln -sf /home/runner/myapp/current/version.txt /home/runner/myapp/version.txt
ln -sf /home/runner/myapp/current/lib         /home/runner/myapp/lib

# Verify — should show -> current/... not -> old/...
ls -la /home/runner/myapp/
```

`ln -sf` creates a symlink, overwriting any existing one (`-f`). The target must exist.""")

    elif 'find-and-replace' in name:
        out.append("""```bash
# Replace old hostname with new one in all config files
find /home/runner/configs -name "*.conf" \\
  -exec sed -i 's/old-server.example.com/new-server.example.com/g' {} +

# Verify no old references remain
grep -r 'old-server' /home/runner/configs/   # should return nothing
grep -r 'new-server' /home/runner/configs/   # should show all files
```

`sed -i` edits files in-place. `s/old/new/g` replaces all occurrences per line.""")

    elif 'find-large' in name:
        out.append("""```bash
# Find files over 100MB
find / -type f -size +100M 2>/dev/null

# Remove them
find / -type f -size +100M -delete 2>/dev/null

# Verify none remain
find / -type f -size +100M 2>/dev/null | wc -l  # should be 0
```

`-size +100M` matches files strictly larger than 100 megabytes.""")

    elif 'suid' in name:
        out.append("""```bash
# Find all SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Remove SUID bit from suspicious ones (not system binaries like sudo/passwd)
chmod u-s /path/to/suspicious/binary

# Write audit report
find / -perm -4000 -type f 2>/dev/null > /home/runner/suid-audit.txt
echo "Audit complete" >> /home/runner/suid-audit.txt
```

`-perm -4000` matches files with the SUID bit set. `chmod u-s` removes it.""")

    elif 'disk-space' in name or 'manage-disk' in name:
        out.append("""```bash
# Remove old log files
find /var/log/myapp -name "*.log.old" -delete

# Clean build cache
rm -rf /tmp/build-cache/*

# Remove old downloads
find /home/runner/downloads -name "*.deb" -delete

# Verify
df -h
```""")

    elif 'environment' in name:
        out.append("""```bash
# Add required environment variables to ~/.bashrc
cat >> ~/.bashrc << 'EOF'
export APP_HOME=/home/runner/app
export APP_PORT=8080
export APP_ENV=production
export LOG_DIRECTORY=/home/runner/app/logs
EOF

# Apply immediately
source ~/.bashrc

# Verify
echo $APP_HOME $APP_PORT $APP_ENV
```""")

    elif 'redirect' in name:
        out.append("""```bash
# Fix the redirections in process.sh:
# > redirects stdout, 2> redirects stderr, >> appends

cat > /home/runner/process.sh << 'SCRIPT'
#!/bin/bash
echo "Processing started" > ~/output/results.txt
echo "Record 1: OK" >> ~/output/results.txt
echo "Record 2: OK" >> ~/output/results.txt
echo "WARN: missing field" 2>> ~/output/errors.log
echo "Run completed" >> ~/output/summary.txt
SCRIPT

bash /home/runner/process.sh
```

Key: `>` overwrites, `>>` appends, `2>` redirects stderr.""")

    elif 'kill' in name or 'runaway' in name:
        out.append("""```bash
# Find the CPU-hogging process
pgrep -f cpu_hog

# Kill it
pkill -f cpu_hog

# Verify it's gone
pgrep -f cpu_hog  # should return nothing
```

`pkill -f` matches against the full command line.""")

    elif 'monitor' in name:
        out.append("""```bash
# Kill rogue processes
pkill -f mem_leak
pkill -f cpu_hog2

# Write system report
cat > /home/runner/system-report.txt << EOF
CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
Memory: $(free -h | awk '/^Mem:/{print $3 "/" $2}')
Rogue processes terminated
EOF
```""")

    elif 'recover' in name:
        out.append("""```bash
# The file was deleted but a process still has it open.
# Find the process holding it:
lsof | grep config.json

# Get PID and file descriptor number from the output, then recover:
PID=$(lsof | grep config.json | awk '{print $2}' | head -1)
FD=$(lsof -p $PID | grep config.json | awk '{print $4}' | tr -d 'rw')

# Copy the file back from /proc
cp /proc/$PID/fd/$FD /home/runner/app/config.json
```

Linux keeps file data alive as long as any process has an open file descriptor, even after `unlink()`. `/proc/PID/fd/` exposes those descriptors.""")

    elif 'users' in name or 'groups' in name:
        out.append("""```bash
sudo groupadd developers
sudo useradd -m -s /bin/bash alice
sudo useradd -m -s /bin/bash bob
sudo usermod -aG developers alice
sudo usermod -aG developers bob
sudo mkdir -p /home/shared
sudo chown root:developers /home/shared
sudo chmod 2775 /home/shared   # setgid: new files inherit group
```""")

    elif 'ssh' in name and 'key' in name:
        out.append("""```bash
# Generate Ed25519 key pair
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add to authorized_keys
cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

The validator checks: key type is `ssh-ed25519`, public key is in `authorized_keys`, `.ssh/` is 700, private key is 600.""")

    elif 'ssh' in name and 'config' in name:
        out.append("""```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa 2>/dev/null || true
chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true
chmod 600 ~/.ssh/config 2>/dev/null || true
chmod 600 ~/.ssh/authorized_keys
```

SSH refuses to use keys with overly permissive permissions.""")

    elif 'rsync' in name:
        out.append("""```bash
mkdir -p /home/runner/backup
rsync -av --delete /home/runner/source/ /home/runner/backup/
ls /home/runner/backup/
```

`-a` preserves permissions/timestamps, `--delete` removes files no longer in source.""")

    elif 'nfs' in name:
        out.append("""```bash
echo "/srv/nfs/shared *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra
sudo service nfs-kernel-server start
sudo mount -t nfs localhost:/srv/nfs/shared /mnt/nfs-test
ls /mnt/nfs-test/
```""")

    elif 'logrotate' in name:
        out.append("""```bash
sudo tee /etc/logrotate.d/myapp << 'EOF'
/var/log/myapp/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 runner runner
}
EOF

sudo logrotate -d /etc/logrotate.d/myapp  # dry-run to verify
```""")

    elif 'swap' in name:
        out.append("""```bash
sudo dd if=/dev/zero of=/swapfile bs=1M count=512
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sudo swapon --show
```""")

    elif 'lvm' in name:
        out.append("""```bash
sudo lvextend -l +100%FREE /dev/vg_data/lv_app
sudo resize2fs /dev/vg_data/lv_app
df -h /mnt/appdata
```""")

    elif 'fstab' in name:
        out.append("""```bash
# Remove the broken entry (references non-existent /dev/sdz99)
sudo sed -i '/sdz99/d' /etc/fstab

# Add correct loop-mount entry
echo '/opt/disk.img  /mnt/data  ext4  loop  0  0' | sudo tee -a /etc/fstab

sudo mount -a
mountpoint /mnt/data
```""")

    elif 'disk-perm' in name:
        out.append("""```bash
sudo chown runner:runner /mnt/data
sudo chmod 755 /mnt/data
ls -la /mnt/data
```""")

    elif 'iptables' in name:
        out.append("""```bash
sudo iptables -F
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -L -n
```""")

    elif 'network-interface' in name:
        out.append("""```bash
sudo ip addr del 192.168.99.99/24 dev dummy0
sudo ip addr add 10.0.0.10/24 dev dummy0
sudo ip link set dummy0 up
ip addr show dummy0
```""")

    elif 'dns' in name and 'fix' in name:
        out.append("""```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
nslookup google.com
```""")

    elif 'apt' in name:
        out.append("""```bash
sudo tee /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF
sudo apt-get update
```""")

    elif 'boot' in name or 'grub' in name:
        out.append("""```bash
sudo tee /etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2>/dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOF
cat /etc/default/grub
```""")

    elif 'locale' in name:
        out.append("""```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
locale
```""")

    elif 'timezone' in name:
        out.append("""```bash
sudo timedatectl set-timezone America/New_York
# or:
sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" | sudo tee /etc/timezone
timedatectl
```""")

    elif 'selinux' in name:
        out.append("""```bash
sudo chcon -R -t httpd_sys_content_t /srv/www/html/
# or restore to policy default:
sudo restorecon -Rv /srv/www/html/
ls -Z /srv/www/html/
```""")

    elif 'sudo' in name and 'configure' in name:
        out.append("""```bash
echo "developer ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/systemctl" \\
  | sudo tee /etc/sudoers.d/developer
sudo chmod 0440 /etc/sudoers.d/developer
sudo visudo -c -f /etc/sudoers.d/developer
sudo -l -U developer
```""")

    elif 'systemd' in name or ('service' in name and 'manage' in name):
        out.append("""```bash
sudo tee /etc/systemd/system/myapp.service << 'EOF'
[Unit]
Description=My Application Service
After=network.target

[Service]
Type=simple
User=runner
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/server.py
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Verify the app runs
python3 /opt/myapp/server.py &
sleep 2 && curl -sf http://localhost:8080 && kill %1
```""")

    elif 'debug' in name and 'permission' in name:
        out.append("""```bash
# Check current permissions
ls -la /home/runner/app/

# Fix ownership and permissions
chmod 755 /home/runner/app
chmod 644 /home/runner/app/*.conf 2>/dev/null || true
chmod +x /home/runner/app/*.sh 2>/dev/null || true
```""")

    elif 'nginx' in name:
        out.append("""```bash
# Check what's wrong with the nginx config
sudo nginx -t

# Common fixes:
# - Wrong server_name or listen port
# - Missing semicolons
# - Wrong root path

# After fixing /etc/nginx/nginx.conf or /etc/nginx/sites-enabled/*:
sudo nginx -t   # must pass
sudo service nginx start
curl http://localhost
```""")

    else:
        # Generic linux — but still show the specific checks
        out.append("```bash")
        for c in checks:
            if c['fail_msg'] and 'docker' not in c['fail_msg'].lower():
                out.append(f"# Fix: {c['fail_msg']}")
        out.append("```\n")
        if notes:
            out.append("**File content requirements:**")
            out.extend(notes)

    return '\n'.join(out)


# ── Ansible ────────────────────────────────────────────────────────────────

def generate_ansible(name, data, checks, validate_sh, starter_files):
    title = data.get('name', name)
    out = ["## What the validator checks\n"]
    for c in checks:
        if c['fail_msg'] and 'syntax' not in c['fail_msg'].lower() and 'daemon' not in c['fail_msg'].lower():
            out.append(f"- {c['fail_msg']}")
    out.append("\n## Solution\n")

    # Extract files that must exist from checks
    required_files = [c['fail_msg'] for c in checks if 'not created' in c['fail_msg'] or 'not found' in c['fail_msg']]
    required_content = [c['fail_msg'] for c in checks if 'should' in c['fail_msg'] or 'must' in c['fail_msg'] or 'wrong' in c['fail_msg']]

    # Get starter playbook for context
    starter = starter_files.get('playbook.yml', '')

    if 'copy-module' in name:
        out.append("""The `copy` module uses either `src:` (copy a file) or `content:` (write inline text) — never both.

```yaml
- name: Copy config from source
  copy:
    src: source_config.txt      # copies the file → db.conf gets "host=localhost"
    dest: /tmp/copymod/db.conf
    mode: "0644"

- name: Create app config with content
  copy:
    content: |
      [app]
      name=myapp
      debug=false
    dest: /tmp/copymod/app.conf
    mode: "0644"

- name: Create readme file
  copy:
    src: source_config.txt
    dest: /tmp/copymod/readme.txt
    mode: "0644"
    owner: root
```

The validator checks that `db.conf` contains `host=localhost` (from `source_config.txt`) and `app.conf` contains `name=myapp` (from inline content).""")

    elif 'handlers' in name:
        out.append("""Handlers only run when notified by a task that reports `changed`.

```yaml
- name: Deploy application
  hosts: local
  become: yes
  handlers:
    - name: restart myapp
      copy:
        content: "restarted\\n"
        dest: /tmp/myapp/restart.log
    - name: reload config
      copy:
        content: "reloaded\\n"
        dest: /tmp/myapp/reload.log
  tasks:
    - name: Create app directory
      file:
        path: /tmp/myapp
        state: directory
    - name: Deploy app config
      copy:
        content: "app_port=8080\\n"
        dest: /tmp/myapp/app.conf
      notify: restart myapp
    - name: Deploy logging config
      copy:
        content: "log_level=INFO\\n"
        dest: /tmp/myapp/logging.conf
      notify: reload config
```

The validator checks that `/tmp/myapp/restart.log` and `/tmp/myapp/reload.log` exist — they're created by the handlers.""")

    elif 'fix-syntax' in name:
        out.append("""Fix the three YAML syntax errors in the playbook:

1. **Extra space before `mode:`** — indentation must be consistent
2. **Missing colon after task name** — `- name Create` → `- name: Create`
3. **Wrong indentation on module parameters** — must be indented under the module name

```yaml
    - name: Create log directory
      file:
        path: /tmp/myproject/logs   # indented under file:, not at same level
        state: directory
        mode: "0755"
```

Run `ansible-playbook --syntax-check` to see the exact line numbers.""")

    elif 'variables' in name:
        out.append("""Define variables in `vars:` and reference them with `{{ var_name }}`.

```yaml
- name: Configure application
  hosts: local
  become: yes
  vars:
    app_name: myapp
    app_port: 8080
    app_env: production
    log_directory: /var/log/myapp
  tasks:
    - name: Create log directory
      file:
        path: "{{ log_directory }}"
        state: directory
    - name: Create config
      copy:
        content: |
          [app]
          name={{ app_name }}
          port={{ app_port }}
          env={{ app_env }}
        dest: "{{ log_directory }}/config.ini"
```

Paths containing variables must be quoted.""")

    elif 'loops' in name:
        out.append("""Use `loop:` to iterate over a list. Access the current item with `item`.

```yaml
  vars:
    apps:
      - name: web
        port: 8080
      - name: api
        port: 5000
      - name: worker
        port: 9000
  tasks:
    - name: Create app directories
      file:
        path: "/tmp/apps/{{ item.name }}"
        state: directory
      loop: "{{ apps }}"

    - name: Create app configs
      copy:
        content: "app={{ item.name }}\\nport={{ item.port }}\\n"
        dest: "/tmp/apps/{{ item.name }}/config.txt"
      loop: "{{ apps }}"
```""")

    elif 'conditionals' in name:
        out.append("""Use `when:` with Jinja2 expressions. No `{{ }}` needed inside `when:`.

```yaml
  vars:
    app_port: 8080
    app_env: production
  tasks:
    - name: Create production config
      copy:
        content: "env=production\\n"
        dest: /tmp/prod_config.txt
      when: app_env == "production"

    - name: Create port info
      copy:
        content: "port={{ app_port }}\\n"
        dest: /tmp/port_info.txt
      when: app_port > 1024
```""")

    elif 'facts' in name:
        out.append("""Ansible auto-collects facts at play start. Reference them directly as variables.

```yaml
  tasks:
    - name: Write system info
      copy:
        content: |
          hostname={{ ansible_hostname }}
          os={{ ansible_distribution }} {{ ansible_distribution_version }}
          kernel={{ ansible_kernel }}
          memory_mb={{ ansible_memtotal_mb }}
        dest: /tmp/system_info.txt
```""")

    elif 'register' in name:
        out.append("""Use `register:` to capture task output. Access `.stdout` for command output.

```yaml
  tasks:
    - name: Get hostname
      command: hostname
      register: hostname_result

    - name: Write report
      copy:
        content: "hostname={{ hostname_result.stdout }}\\n"
        dest: /tmp/system_report.txt
```""")

    elif 'set-fact' in name:
        out.append("""Use `set_fact:` to create computed variables during playbook execution.

```yaml
  tasks:
    - name: Get date
      command: date +%Y-%m-%d
      register: date_output

    - name: Set derived facts
      set_fact:
        deploy_date: "{{ date_output.stdout }}"
        app_version: "2.1.0"
        deploy_tag: "v2.1.0-{{ date_output.stdout }}"

    - name: Write deployment info
      copy:
        content: "version={{ app_version }}\\ndate={{ deploy_date }}\\n"
        dest: /tmp/deploy_info.txt
```""")

    elif 'error' in name:
        out.append("""Use `block`/`rescue`/`always` for structured error handling.

```yaml
  tasks:
    - name: Create work directory
      file:
        path: /tmp/errorhandling
        state: directory

    - block:
        - name: Attempt risky operation
          command: cat /tmp/nonexistent_file_12345.txt

      rescue:
        - name: Handle the error
          copy:
            content: "Error caught: file not found\\n"
            dest: /tmp/errorhandling/error.log
        - name: Create fallback data
          copy:
            content: "fallback data\\n"
            dest: /tmp/errorhandling/data.txt

      always:
        - name: Write completion marker
          copy:
            content: "completed\\n"
            dest: /tmp/errorhandling/done.txt
```

`rescue` runs if any `block` task fails. `always` runs regardless.""")

    elif 'assert' in name:
        out.append("""Use `assert` to validate conditions with clear failure messages.

```yaml
  tasks:
    - name: Check memory
      assert:
        that:
          - ansible_memtotal_mb >= 512
        fail_msg: "Need at least 512MB RAM"
        success_msg: "Memory OK: {{ ansible_memtotal_mb }}MB"

    - name: Write results
      copy:
        content: "assertions passed\\nmemory={{ ansible_memtotal_mb }}MB\\n"
        dest: /tmp/assert_results.txt
```""")

    elif 'tags' in name:
        out.append("""Add `tags:` to tasks to allow selective execution.

```yaml
  tasks:
    - name: Install packages
      apt:
        name: curl
        state: present
      tags: [packages, install]

    - name: Deploy config
      copy:
        content: "app=myapp\\n"
        dest: /tmp/app.conf
      tags: [config, deploy]
```

Run with: `ansible-playbook playbook.yml --tags config`""")

    elif 'template' in name:
        out.append("""Fix the Jinja2 syntax errors in `app.conf.j2` and use the `template` module.

Common errors to fix:
- `{{ app_name }` → `{{ app_name }}` (missing closing brace)
- `{% if enable_ssl` → `{% if enable_ssl %}` (missing closing `%}`)

```yaml
  tasks:
    - name: Deploy config from template
      template:
        src: app.conf.j2
        dest: /tmp/app.conf
        mode: "0644"
```""")

    elif 'vault' in name:
        out.append("""Create a vault password file, encrypt secrets, and reference them in the playbook.

```bash
# Create vault password file
echo "mysecretpassword" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Create encrypted secrets file
ansible-vault create --vault-password-file ~/.vault_pass secrets.yml
# Add: db_password: supersecret123
# Add: api_key: abc123xyz
```

```yaml
- name: Use vault secrets
  hosts: local
  vars_files:
    - secrets.yml
  tasks:
    - name: Write config
      copy:
        content: "db_pass={{ db_password }}\\n"
        dest: /tmp/app-secret.conf
```

Run: `ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.vault_pass`""")

    elif 'privilege' in name:
        out.append("""Use `become: yes` and `become_user:` — never the deprecated `sudo:`.

```yaml
- name: Privilege escalation
  hosts: local
  become: yes          # become root by default
  tasks:
    - name: Create root-owned file
      copy:
        content: "root owned\\n"
        dest: /tmp/priv-test/root_file.txt

    - name: Write as deploy user
      copy:
        content: "deploy user\\n"
        dest: /tmp/priv-test/deploy_file.txt
      become_user: deploy
      become: yes
```""")

    elif 'service' in name:
        out.append("""Use the `command` module to manage the fake service (no systemd in container).

```yaml
  tasks:
    - name: Create service config
      copy:
        content: |
          [service]
          name=myservice
          port=9090
        dest: /tmp/myservice-conf/service.conf
        mode: "0644"

    - name: Start the service
      command: myservice start
      register: start_result

    - name: Check status
      command: myservice status
      register: service_status

    - name: Write status
      copy:
        content: "{{ service_status.stdout }}\\n"
        dest: /tmp/myservice-conf/status.txt
```""")

    elif 'package' in name:
        out.append("""Use `state: present` (not `state: installed`) and `name:` (not `pkg:`).

```yaml
  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install packages
      apt:
        name: "{{ item }}"
        state: present      # valid: present, absent, latest
      loop:
        - curl
        - jq
        - tree              # use name:, not pkg:
```""")

    elif 'user' in name:
        out.append("""Use `name:` (not `username:`) for the user module.

```yaml
  tasks:
    - name: Create group
      group:
        name: deploy
        state: present

    - name: Create user
      user:
        name: deploy        # correct param — not "username:"
        shell: /bin/bash
        group: deploy
        create_home: yes
        state: present
```""")

    elif 'lineinfile' in name:
        out.append("""Use `lineinfile` to add or replace specific lines.

```yaml
  tasks:
    - name: Set max connections
      lineinfile:
        path: /tmp/app.conf
        regexp: '^max_connections'
        line: 'max_connections = 100'
        create: yes

    - name: Remove deprecated option
      lineinfile:
        path: /tmp/app.conf
        regexp: '^deprecated_option'
        state: absent
```

`regexp:` matches the line to replace. If no match, `line:` is appended.""")

    elif 'blockinfile' in name:
        out.append("""Use `blockinfile` to insert a block of text identified by marker comments.

```yaml
  tasks:
    - name: Add server block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        block: |
          server {
              listen 80;
              server_name example.com;
          }
        create: yes
```

`{mark}` is replaced with `BEGIN` and `END` in the marker comments.""")

    elif 'include' in name or 'import' in name:
        out.append("""Replace deprecated `include:` with `import_tasks:` or `include_tasks:`.

```yaml
  tasks:
    - import_tasks: tasks/setup_dirs.yml    # static — loaded at parse time
    - include_tasks: tasks/deploy_app.yml   # dynamic — loaded at runtime
```

`include:` was removed in Ansible 2.8. Use `import_tasks:` for most cases.""")

    elif 'inventory' in name:
        out.append("""Fix the inventory syntax errors:

```ini
[webservers]
localhost ansible_connection=local   # = required, not a space

[dbservers]
localhost ansible_connection=local

[production:children]               # :children not :child
webservers
dbservers

[production:vars]                   # :vars not :var
env=production
```""")

    elif 'delegation' in name:
        out.append("""Use `delegate_to:` to run a task on a different host.

```yaml
  tasks:
    - name: Deploy config
      copy:
        content: "version=1.0\\n"
        dest: /tmp/delegation-test/app.conf

    - name: Log to monitoring (runs on localhost)
      copy:
        content: "deployed at {{ ansible_date_time.iso8601 }}\\n"
        dest: /tmp/delegation-test/monitoring.txt
      delegate_to: localhost
```""")

    elif 'serial' in name:
        out.append("""Add `serial:` to the play to control rolling deployment batch size.

```yaml
- name: Rolling deployment
  hosts: webservers
  become: yes
  serial: 1          # update 1 host at a time; use "50%" for percentage
  tasks:
    - name: Deploy app
      copy:
        content: "version=2.0\\n"
        dest: /tmp/serial-deploy/app.conf
    - name: Write marker
      copy:
        content: "deployed\\n"
        dest: /tmp/serial-deploy/deployed.txt
```""")

    elif 'roles' in name:
        out.append("""Create the role directory structure and call it from the playbook.

```bash
mkdir -p ~/ansible-project/roles/webserver/{tasks,defaults}
```

```yaml
# roles/webserver/tasks/main.yml
- name: Create web directory
  file:
    path: /tmp/webserver
    state: directory
- name: Deploy index
  copy:
    content: "<h1>Hello</h1>"
    dest: /tmp/webserver/index.html
```

```yaml
# playbook.yml
- name: Deploy
  hosts: local
  become: yes
  roles:
    - webserver
```""")

    elif 'callback' in name:
        out.append("""Fix `ansible.cfg` — use `callbacks_enabled` (not the deprecated `callback_whitelist`).

```ini
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
```

```bash
cat > ~/ansible-project/ansible.cfg << 'EOF'
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
EOF
```""")

    elif 'lookup' in name:
        out.append("""Use lookup plugins to read data from external sources.

```yaml
  tasks:
    - name: Read from file
      copy:
        content: "{{ lookup('file', '/etc/hostname') }}"
        dest: /tmp/hostname.txt

    - name: Read env variable
      copy:
        content: "path={{ lookup('env', 'PATH') }}\\n"
        dest: /tmp/env_info.txt
```""")

    elif 'command' in name and 'shell' in name:
        out.append("""Use `command:` for simple commands, `shell:` only when you need pipes/redirects.

```yaml
  tasks:
    - name: Get hostname (no shell features needed)
      command: hostname
      register: hostname_out

    - name: Get disk usage with pipe (needs shell)
      shell: df -h | grep -v tmpfs | tail -1
      register: disk_out

    - name: Write summary
      copy:
        content: "hostname={{ hostname_out.stdout }}\\n"
        dest: /tmp/cmdshell/summary.txt
```""")

    elif 'fix-ansible' in name or 'fix_ansible' in name:
        out.append("""Fix the broken playbook so it runs without errors.

```bash
# Check syntax first
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# Run with verbose output to see what's failing
ansible-playbook -i inventory.ini playbook.yml -v
```

Common issues to look for:
- `src:` and `content:` used together in `copy` module (mutually exclusive)
- Missing `dest:` in copy tasks
- Wrong indentation
- Invalid module parameter names""")

    else:
        # Generic ansible — show what files must be created
        out.append("```yaml\n# playbook.yml\n- name: Solution\n  hosts: local\n  become: yes\n  tasks:")
        for c in checks:
            if 'not created' in c['fail_msg'] or 'not found' in c['fail_msg']:
                m = re.search(r'(/tmp/\S+|~/\S+)', c['fail_msg'])
                if m:
                    out.append(f"    - name: Create {m.group(1)}\n      copy:\n        content: \"solution\\n\"\n        dest: {m.group(1)}")
        out.append("```")

    out.append("\n```bash\nansible-playbook -i inventory.ini playbook.yml\n```")
    return '\n'.join(out)


# ── Docker ─────────────────────────────────────────────────────────────────

def generate_docker(name, data, checks, validate_sh, starter_files):
    out = ["## What the validator checks\n"]
    for c in checks:
        if c['fail_msg'] and 'daemon' not in c['fail_msg'].lower():
            out.append(f"- {c['fail_msg']}")
    out.append("\n## Solution\n")

    # Extract image names the validator expects
    image_checks = [c for c in checks if 'image' in c['fail_msg'].lower() or ':latest' in c['fail_msg'] or ':' in c['fail_msg']]
    container_checks = [c for c in checks if 'container' in c['fail_msg'].lower() or 'running' in c['fail_msg'].lower()]

    if 'build-image' in name:
        out.append("""```bash
mkdir -p ~/myapp
cat > ~/myapp/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Hello from myapp" > /app/hello.txt
CMD ["cat", "/app/hello.txt"]
EOF

docker build -t myapp:latest ~/myapp/
docker images | grep myapp
```

The validator checks that `myapp:latest` exists in `docker images`.""")

    elif 'fix-dockerfile' in name:
        # Read the broken Dockerfile from setup.sh
        setup = starter_files.get('setup.sh', '')
        out.append("""```bash
# Read the broken Dockerfile
cat ~/webapp/Dockerfile

# Check the build error
docker build -t webapp:latest ~/webapp/ 2>&1 | head -20
```

Common Dockerfile errors to fix:
- Typo in base image name (e.g. `ngix` → `nginx`)
- Missing `COPY` before `RUN`
- Wrong `EXPOSE` port
- `CMD` using wrong syntax

After fixing:
```bash
docker build -t webapp:latest ~/webapp/
```

The validator checks that `webapp:latest` exists.""")

    elif 'build-args' in name:
        out.append("""```bash
cat > ~/myapp/Dockerfile << 'EOF'
FROM alpine:latest
ARG APP_VERSION=1.0.0
ARG APP_ENV=production
RUN echo "version=$APP_VERSION env=$APP_ENV" > /app/config.txt
CMD ["cat", "/app/config.txt"]
EOF

docker build -t myapp:latest \\
  --build-arg APP_VERSION=2.0.0 \\
  --build-arg APP_ENV=staging \\
  ~/myapp/
```""")

    elif 'compose' in name:
        out.append("""Fix the two errors in `docker-compose.yml`:

1. `ngix` → `nginx` (image name typo)
2. `api` service was indented under `web` — it must be a sibling

```yaml
version: "3"
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
  api:
    image: python:3-alpine
    ports:
      - "5000:5000"
    command: python -m http.server 5000
```

```bash
docker compose -f ~/project/docker-compose.yml up -d
docker compose -f ~/project/docker-compose.yml ps
```""")

    elif 'volume' in name:
        out.append("""```bash
# Create a named volume and mount it
docker volume create mydata

docker run -d \\
  --name databox \\
  -v mydata:/data \\
  alpine sleep infinity

# Write data and verify it persists
docker exec databox sh -c "echo 'hello' > /data/test.txt"
docker exec databox cat /data/test.txt
```""")

    elif 'env' in name:
        out.append("""```bash
# Run with -e flags
docker run -d \\
  --name envbox \\
  -e APP_ENV=production \\
  -e APP_PORT=3000 \\
  -e APP_DEBUG=false \\
  alpine sleep infinity

# Create env file for second container
cat > ~/app.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

docker run -d \\
  --name envbox2 \\
  --env-file ~/app.env \\
  alpine sleep infinity

# Verify
docker exec envbox env | grep APP_
```""")

    elif 'bridge' in name:
        out.append("""```bash
docker network create \\
  --driver bridge \\
  --subnet 172.20.0.0/16 \\
  --gateway 172.20.0.1 \\
  appnet

docker run -d \\
  --name webhost \\
  --network appnet \\
  --ip 172.20.0.10 \\
  nginx:alpine

docker run -d \\
  --name checker \\
  --network appnet \\
  alpine sleep infinity

# Verify DNS resolution by container name
docker exec checker ping -c 2 webhost
```""")

    elif 'create-network' in name:
        out.append("""```bash
docker network create mynet

docker run -d --name web --network mynet nginx:alpine
docker run -d --name tester --network mynet alpine sleep infinity

# Verify containers can reach each other by name
docker exec tester ping -c 2 web
docker exec tester wget -qO- http://web
```""")

    elif 'container-networking' in name:
        out.append("""The `web` container is on `net-web` and `client` is on `net-client` — they can't communicate. Connect `client` to `net-web`:

```bash
docker network connect net-web client

# Verify
docker exec client curl -sf http://web:8080
```""")

    elif 'expose' in name or ('port' in name and 'fix' not in name and 'container' not in name):
        out.append("""```bash
# Remove the container without port mapping
docker rm -f webserver

# Re-run with port mapping
docker run -d \\
  --name webserver \\
  -p 8080:80 \\
  nginx:alpine

curl http://localhost:8080
```

`-p host_port:container_port` maps a host port to a container port.""")

    elif 'exec' in name:
        out.append("""```bash
# Run an interactive shell
docker exec -it workbox sh

# Run a single command
docker exec workbox ls /

# Create a file inside the container
docker exec workbox sh -c "echo 'hello' > /tmp/test.txt"
docker exec workbox cat /tmp/test.txt
```

`-it` allocates a pseudo-TTY for interactive use.""")

    elif 'copy' in name and 'file' in name:
        out.append("""```bash
# Copy FROM container TO host
docker cp filebox:/var/log/app.log ~/extracted.log

# Copy FROM host TO container
echo "mode=active" > ~/inject.conf
docker cp ~/inject.conf filebox:/etc/inject.conf

# Verify
cat ~/extracted.log
docker exec filebox cat /etc/inject.conf
```""")

    elif 'inspect' in name:
        out.append("""```bash
# Extract container metadata
IP=$(docker inspect mystery --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
IMAGE=$(docker inspect mystery --format '{{.Config.Image}}')
HOSTNAME=$(docker inspect mystery --format '{{.Config.Hostname}}')

cat > ~/report.txt << EOF
Container: mystery
IP Address: $IP
Image: $IMAGE
Hostname: $HOSTNAME
EOF
```""")

    elif 'logs' in name:
        out.append("""```bash
# Check logs for each container
docker logs app1
docker logs app2
docker logs app3

# Find the one with errors
for c in app1 app2 app3; do
  echo "=== $c ==="
  docker logs $c 2>&1 | grep -i error | head -3
done

# Write the report (container name on line 1, error on line 2)
CONTAINER="app2"
ERROR=$(docker logs $CONTAINER 2>&1 | grep ERROR | head -1)
printf "%s\\n%s\\n" "$CONTAINER" "$ERROR" > ~/error-report.txt
```""")

    elif 'restart' in name:
        out.append("""```bash
docker run -d --name always-up    --restart always          alpine sleep infinity
docker run -d --name on-fail      --restart on-failure:3    alpine sleep infinity
docker run -d --name unless-manual --restart unless-stopped  alpine sleep infinity

# Verify
docker inspect always-up --format '{{.HostConfig.RestartPolicy.Name}}'
```""")

    elif 'healthcheck' in name:
        out.append("""```bash
docker run -d \\
  --name healthyweb \\
  --health-cmd "wget -qO- http://localhost/ || exit 1" \\
  --health-interval 10s \\
  --health-timeout 5s \\
  --health-retries 3 \\
  nginx:alpine

sleep 15
docker inspect healthyweb --format '{{.State.Health.Status}}'
```""")

    elif 'resource' in name and 'limit' in name:
        out.append("""```bash
docker run -d \\
  --name limited \\
  --memory 128m \\
  --cpus 0.5 \\
  nginx:alpine

# Verify
docker inspect limited --format '{{.HostConfig.Memory}}'    # 134217728 (128MB)
docker inspect limited --format '{{.HostConfig.NanoCpus}}'  # 500000000 (0.5 CPU)
```""")

    elif 'multi-stage' in name:
        out.append("""```dockerfile
# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o server .

# Stage 2: minimal runtime
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
```

```bash
docker build -t goapp:latest ~/goapp/
docker images goapp  # should be well under 50MB
```

`COPY --from=builder` copies only the compiled binary — the Go toolchain (~300MB) stays in the builder stage.""")

    elif 'image-layers' in name:
        out.append("""Combine `RUN` commands and clean apt cache in the same layer:

```dockerfile
FROM ubuntu:22.04
# Bad: each RUN creates a layer, cache not cleaned
# RUN apt-get update
# RUN apt-get install -y curl

# Good: single layer, cache cleaned in same RUN
RUN apt-get update && \\
    apt-get install -y --no-install-recommends curl wget && \\
    rm -rf /var/lib/apt/lists/*
```

```bash
docker build -t optimized:latest ~/myapp/
docker history optimized:latest
```""")

    elif 'save' in name or 'load' in name:
        out.append("""```bash
# Tag the image
docker tag alpine:latest savetest:v1

# Save to tar
docker save savetest:v1 -o ~/savetest.tar

# Remove original
docker rmi savetest:v1

# Load from tar
docker load -i ~/savetest.tar

# Tag as restored
docker tag savetest:v1 restored:v1

# Verify
docker run --rm restored:v1 echo "restored OK"
```""")

    elif 'tag' in name:
        out.append("""```bash
docker build -t tagme:v1.0 ~/myapp/

# Add additional tags (all point to same image ID)
docker tag tagme:v1.0 tagme:v1.0.0
docker tag tagme:v1.0 myregistry/tagme:v1.0

docker images | grep tagme
```""")

    elif 'prune' in name:
        out.append("""```bash
# Remove stopped containers
docker rm old1 old2 old3

# Remove unused networks
docker network rm unused-net1 unused-net2

# Remove dangling images
docker image prune -f

# Verify
docker ps -a --filter status=exited
docker network ls
```""")

    elif 'overlay' in name:
        out.append("""```bash
docker swarm init
docker network create --driver overlay --attachable myoverlay

docker service create \\
  --name web-service \\
  --network myoverlay \\
  --replicas 2 \\
  nginx:alpine

docker network ls | grep overlay
docker service ls
```""")

    elif 'fix-build-context' in name:
        out.append("""```bash
cat > ~/bigproject/.dockerignore << 'EOF'
data/
node_modules/
*.log
.git/
tmp/
EOF

docker build -t slim-project:latest ~/bigproject/
```

`.dockerignore` prevents large directories from being sent to the Docker daemon.""")

    elif 'fix-dns' in name:
        out.append("""```bash
docker rm -f dnsbox

docker run -d \\
  --name dnsbox-fixed \\
  --dns 8.8.8.8 \\
  alpine sleep infinity

docker exec dnsbox-fixed nslookup google.com
```

The broken container used `192.0.2.1` (a documentation IP). `--dns 8.8.8.8` sets a working resolver.""")

    elif 'fix-entrypoint' in name:
        out.append("""Fix the typo and switch to exec form (JSON array):

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Fix: "pythonn" → "python3", use exec form not shell form
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t fixed-server:latest ~/server/
docker run -d --name myserver fixed-server:latest
docker ps | grep myserver
```

Exec form makes your app PID 1 — shell form wraps it in `/bin/sh -c`.""")

    elif 'fix-permissions' in name:
        out.append("""```dockerfile
FROM alpine:latest
RUN adduser -D -u 1001 appuser && \\
    mkdir -p /app/data && \\
    chown -R appuser:appuser /app
USER appuser
WORKDIR /app
CMD ["sh", "-c", "while true; do sleep 1; done"]
```

```bash
docker build -t fixed-app:latest ~/app/
docker run -d --name permbox fixed-app:latest
docker exec permbox id   # should show uid=1001
```""")

    elif 'fix-storage' in name:
        out.append("""```bash
docker rm -f storebox

docker run -d \\
  --name storebox \\
  -v ~/storage:/data \\
  -u $(id -u):$(id -g) \\
  --tmpfs /tmp \\
  alpine sleep infinity

docker exec storebox id
docker exec storebox touch /tmp/test.txt && echo "tmpfs writable"
```""")

    elif 'debug' in name or 'crashed' in name:
        out.append("""```bash
# Check container status and exit code
docker ps -a | grep webapp
docker inspect webapp --format '{{.State.ExitCode}}'

# Read the logs
docker logs webapp

# Debug interactively with same image
docker run -it --rm --entrypoint sh \\
  $(docker inspect webapp --format '{{.Config.Image}}')

# After fixing, restart
docker start webapp
```""")

    elif 'linking' in name:
        out.append("""```bash
docker run -d --name redis-server redis:alpine

docker run -d \\
  --name redis-client \\
  --link redis-server:db \\
  alpine sleep infinity

# Verify the link (db resolves to redis-server's IP)
docker exec redis-client ping -c 2 db
```""")

    elif 'read-only' in name:
        out.append("""```bash
docker run -d \\
  --name readonly-web \\
  --read-only \\
  --tmpfs /var/cache/nginx \\
  --tmpfs /var/run \\
  --tmpfs /tmp \\
  nginx:alpine

# Verify
docker exec readonly-web touch /test.txt 2>&1   # should fail
docker exec readonly-web touch /tmp/test.txt    # should succeed
```""")

    elif 'tmpfs' in name:
        out.append("""```bash
docker run -d \\
  --name tmpbox \\
  --tmpfs /app/cache:size=64m \\
  alpine sleep infinity

docker run -d \\
  --name securebox \\
  --tmpfs /run/secrets:noexec,nosuid,size=32m \\
  alpine sleep infinity

docker inspect tmpbox --format '{{json .HostConfig.Tmpfs}}'
```""")

    elif 'user-namespace' in name:
        out.append("""```dockerfile
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh && \\
    adduser -D -u 1001 appuser
USER appuser
CMD ["./app.sh"]
```

```bash
docker build -t safebox:latest ~/nonroot/
docker run -d --name safebox safebox:latest sleep infinity
docker exec safebox id -u   # should return 1001
```""")

    elif 'signal' in name:
        out.append("""Fix the Dockerfile to use exec form so signals reach the process:

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Shell form (broken): ENTRYPOINT python3 app.py
# Exec form (fixed):
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t signalapp:fixed ~/signalapp/
docker inspect signalapp:fixed --format '{{.Config.Entrypoint}}'
# Should show: [python3 app.py]  — not [/bin/sh -c python3 app.py]
```""")

    elif 'init' in name:
        out.append("""```bash
docker run -d --name with-init --init alpine sleep infinity

# Verify PID 1 is an init process (tini)
docker exec with-init ps -o comm= -p 1   # should show "init" or "tini"
```

`--init` injects `tini` as PID 1, which properly handles zombie processes and signal forwarding.""")

    elif 'container-restart' in name:
        out.append("""```bash
docker run -d --name always-up     --restart always          alpine sleep infinity
docker run -d --name on-fail       --restart on-failure:3    alpine sleep infinity
docker run -d --name unless-manual --restart unless-stopped  alpine sleep infinity
```""")

    else:
        # Generic docker — show what images/containers must exist
        out.append("```bash")
        for c in checks:
            if 'not found' in c['fail_msg'] or 'not running' in c['fail_msg']:
                out.append(f"# Fix: {c['fail_msg']}")
        out.append("```")

    return '\n'.join(out)


# ── Kubernetes ─────────────────────────────────────────────────────────────

def generate_k8s(name, data, checks, validate_sh, starter_files):
    out = ["## What the validator checks\n"]
    for c in checks:
        if c['fail_msg'] and 'dry-run' not in c['fail_msg'].lower():
            out.append(f"- {c['fail_msg']}")
    out.append("\n## Solution\n")

    # Extract required field values from grep checks
    required = {}
    for c in checks:
        m = re.search(r"grep -q '([^']+)'", c['block'])
        if m:
            required[c['fail_msg']] = m.group(1)

    # Read broken starter YAML from setup.sh if available
    setup = starter_files.get('setup.sh', '')

    if 'create-deployment' in name:
        out.append("""```yaml
# ~/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply --dry-run=server -f ~/deployment.yaml
```

`spec.selector.matchLabels` must match `spec.template.metadata.labels` exactly.""")

    elif 'fix-service' in name or 'create-service' in name:
        out.append("""```yaml
# ~/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app        # must match Pod labels
  ports:
  - port: 80            # integer, not string
    targetPort: 8080    # integer, not string
  type: ClusterIP
```

The validator checks: `apiVersion: v1`, `app: web-app` in selector, `port: 80`, `targetPort: 8080`.""")

    elif 'fix-volume' in name:
        out.append("""The `volumeMounts[].name` must exactly match `volumes[].name`.

```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: config-vol      # must match volumes[].name below
      mountPath: /etc/config
    - name: data-vol
      mountPath: /data
  volumes:
  - name: config-vol        # matches volumeMounts[0].name
    configMap:
      name: app-config
  - name: data-vol
    emptyDir: {}
```""")

    elif 'fix-configmap' in name:
        out.append("""ConfigMap values must be strings — wrap numbers in quotes.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "localhost"
  DATABASE_PORT: "5432"      # must be "5432" not 5432
  MAX_CONNECTIONS: "100"     # must be "100" not 100
  APP_ENV: "production"
```""")

    elif 'fix-labels' in name or 'fix-selector' in name:
        out.append("""The Deployment `matchLabels`, Pod template labels, and Service `selector` must all match.

```yaml
# deployment.yaml
spec:
  selector:
    matchLabels:
      app: api-server      # must match template labels
  template:
    metadata:
      labels:
        app: api-server    # Pods get this label
```

```yaml
# service.yaml
spec:
  selector:
    app: api-server        # must match Pod labels
```""")

    elif 'fix-rbac' in name:
        out.append("""```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role           # must be "Role" not "ClusterRole"
  name: pod-reader     # must match Role name above
  apiGroup: rbac.authorization.k8s.io
```""")

    elif 'fix-hpa' in name:
        out.append("""```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment      # case-sensitive: "Deployment" not "deployment"
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```""")

    elif 'fix-ingress' in name:
        out.append("""```yaml
apiVersion: networking.k8s.io/v1    # not extensions/v1beta1 (removed in 1.22)
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix              # required in networking.k8s.io/v1
        backend:
          service:                    # new format (not serviceName/servicePort)
            name: web-svc
            port:
              number: 80
```""")

    elif 'fix-network-policy' in name:
        out.append("""```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
  egress:
  - {}              # allow all egress
```""")

    elif 'fix-pvc' in name:
        out.append("""```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi    # PVCs request "storage", not "cpu" or "memory"
```""")

    elif 'fix-statefulset' in name:
        out.append("""Two fixes needed: headless Service (`clusterIP: None`) and `serviceName` in StatefulSet.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None        # headless — required for StatefulSet DNS
  selector:
    app: postgres
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless   # links to the headless service
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
```""")

    elif 'fix-tolerations' in name:
        out.append("""```yaml
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"   # must match the taint exactly
```""")

    elif 'fix-node-selector' in name:
        out.append("""```yaml
spec:
  nodeSelector:
    disktype: ssd    # must match node label exactly
```

Check available node labels: `kubectl get nodes --show-labels`""")

    elif 'fix-pod-security' in name:
        out.append("""```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```""")

    elif 'fix-env-vars' in name:
        out.append("""```yaml
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: APP_ENV
      value: "production"
    - name: APP_PORT
      value: "8080"        # must be string "8080", not integer 8080
    command: ["sleep", "infinity"]
```""")

    elif 'fix-dns' in name:
        out.append("""```yaml
spec:
  dnsPolicy: ClusterFirst    # not "None" without a dnsConfig block
  containers:
  - name: app
    image: alpine
    command: ["sleep", "infinity"]
```""")

    elif 'fix-image-pull' in name:
        out.append("""```yaml
spec:
  containers:
  - name: app
    image: nginx:1.25           # fix typo in image name/tag
    imagePullPolicy: IfNotPresent
```""")

    elif 'fix-container-port' in name:
        out.append("""```yaml
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80    # integer, not string "80"
```""")

    elif 'crashlooping' in name:
        out.append("""The pod crashes because `nginx-wrong` doesn't exist in the image.

Fix `~/pod.yaml` — either remove the `command:` entirely (use image default) or use the correct binary:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: nginx:alpine
    # Option 1: remove command entirely (recommended)
    ports:
    - containerPort: 80
```

Or keep a command with the correct binary:
```yaml
    command: ["nginx", "-g", "daemon off;"]
```

```bash
kubectl apply -f ~/pod.yaml
kubectl get pod web-app -w   # watch it reach Running
```""")

    elif 'init-containers' in name:
        out.append("""```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init-setup
    image: alpine
    command: ["sh", "-c", "echo 'initialized' > /shared/init.txt"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  containers:
  - name: app
    image: alpine
    command: ["sh", "-c", "cat /shared/init.txt && sleep infinity"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
```

Init containers run to completion before app containers start.""")

    elif 'liveness' in name:
        out.append("""```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
```""")

    elif 'multi-container' in name:
        out.append("""```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container
spec:
  containers:
  - name: web
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: content
    image: busybox
    command: ["sh", "-c", "while true; do echo '<h1>Hello</h1>' > /data/index.html; sleep 30; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```""")

    elif 'resource-limits' in name:
        out.append("""```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

`100m` = 0.1 CPU cores. `requests` is used for scheduling; `limits` is the hard cap.""")

    elif 'rolling-update' in name:
        out.append("""```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 10
```""")

    elif 'sidecar' in name:
        out.append("""```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/nginx
  - name: log-shipper
    image: busybox
    command: ["sh", "-c", "tail -f /logs/access.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /logs
      readOnly: true
  volumes:
  - name: log-volume
    emptyDir: {}
```""")

    elif 'create-namespace' in name:
        out.append("""```yaml
# ~/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    env: staging
```

```bash
kubectl apply --dry-run=server -f ~/namespace.yaml
```""")

    elif 'create-job' in name:
        out.append("""```yaml
# ~/job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  template:
    spec:
      restartPolicy: Never    # required for Jobs — not "Always"
      containers:
      - name: processor
        image: alpine
        command: ["sh", "-c", "echo 'processing' && sleep 5 && echo 'done'"]
```""")

    elif 'create-cronjob' in name:
        out.append("""```yaml
# ~/cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: alpine
            command: ["sh", "-c", "echo 'backup complete'"]
```""")

    elif 'create-daemonset' in name:
        out.append("""```yaml
# ~/daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: collector
        image: alpine
        command: ["sh", "-c", "while true; do echo 'collecting'; sleep 60; done"]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```""")

    elif 'create-secret' in name:
        out.append("""```yaml
# ~/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_USER: YWRtaW4=        # base64("admin")
  DB_PASS: c3VwZXJzZWNyZXQ=  # base64("supersecret")
```

```bash
# Encode values
echo -n "admin" | base64
echo -n "supersecret" | base64
```""")

    elif 'create-pdb' in name:
        out.append("""```yaml
# ~/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: web-app
```""")

    elif 'create-limit-range' in name:
        out.append("""```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
  - type: Container
    default:
      cpu: "500m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "1Gi"
```""")

    elif 'create-resource-quota' in name:
        out.append("""```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "4Gi"
    limits.cpu: "8"
    limits.memory: "8Gi"
    pods: "20"
    services: "10"
```""")

    elif 'create-priority-class' in name:
        out.append("""```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority workloads"
```""")

    elif 'create-service-account' in name:
        out.append("""```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: app-sa-binding
  namespace: default
subjects:
- kind: ServiceAccount
  name: app-sa
  namespace: default
roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
```""")

    else:
        out.append("```bash\n# Apply your manifest\nkubectl apply --dry-run=server -f ~/manifest.yaml\n```\n")
        if required:
            out.append("**Required field values:**")
            for fail_msg, pattern in required.items():
                out.append(f"- `{pattern}` — {fail_msg}")

    return '\n'.join(out)


# ── Terraform ──────────────────────────────────────────────────────────────

def generate_terraform(name, data, checks, validate_sh, starter_files):
    out = ["## What the validator checks\n"]
    for c in checks:
        if c['fail_msg'] and 'init failed' not in c['fail_msg'] and 'validate failed' not in c['fail_msg']:
            out.append(f"- {c['fail_msg']}")
    out.append("\n## Solution\n")

    if 'fix-syntax' in name:
        out.append("""The broken `main.tf` has a missing closing brace `}`. Find it and fix it:

```bash
cd ~/terraform-project
terraform validate 2>&1   # shows the exact line with the error
```

```hcl
# main.tf — fixed (add the missing closing brace)
resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/config.txt"
}   # ← this was missing
```

```bash
terraform validate   # must pass
```""")

    elif 'terraform-fmt' in name:
        out.append("""```bash
cd ~/terraform-project
terraform fmt

# Verify it's now formatted
terraform fmt -check   # exits 0 if already formatted
```

`terraform fmt` enforces canonical HCL style: 2-space indentation, aligned `=` signs, consistent spacing.""")

    elif 'variables' in name:
        out.append("""```hcl
# main.tf
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "my-app"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}

variable "file_count" {
  description = "Number of config files"
  type        = number
  default     = 3
}

resource "local_file" "config" {
  count    = var.file_count
  content  = "project=${var.project_name}\\nenv=${var.environment}\\n"
  filename = "${path.module}/config-${count.index}.txt"
}
```

```bash
terraform apply -auto-approve
```""")

    elif 'outputs' in name:
        out.append("""```hcl
resource "random_pet" "server" { length = 2 }
resource "local_file" "config" {
  content  = "server=${random_pet.server.id}\\n"
  filename = "${path.module}/config.txt"
}
resource "random_integer" "priority" { min = 1; max = 100 }

output "pet_name" {
  description = "The generated server name"
  value       = random_pet.server.id
}
output "config_path" {
  description = "Path to the config file"
  value       = local_file.config.filename
}
output "random_number" {
  description = "A random priority number"
  value       = random_integer.priority.result
}
```

```bash
terraform apply -auto-approve
terraform output
```""")

    elif 'state-management' in name:
        out.append("""```bash
cd ~/terraform-project

# Step 1: rename in state (no destroy/recreate)
terraform state mv random_pet.server random_pet.app_server

# Step 2: update main.tf to match
sed -i 's/resource "random_pet" "server"/resource "random_pet" "app_server"/' main.tf
sed -i 's/random_pet\.server\./random_pet.app_server./g' main.tf

# Step 3: verify no changes pending
terraform plan   # should show "No changes"
```

`terraform state mv` renames a resource in state without destroying it.""")

    elif 'import' in name:
        out.append("""```hcl
# main.tf — add a resource matching the existing file
resource "local_file" "app_config" {
  content  = file("${path.module}/app-config.txt")
  filename = "${path.module}/app-config.txt"
}
```

```bash
cd ~/terraform-project
terraform import local_file.app_config ~/terraform-project/app-config.txt
terraform plan   # should show "No changes"
```""")

    elif 'backend-config' in name:
        out.append("""```hcl
terraform {
  required_providers {
    local = { source = "hashicorp/local"; version = "~> 2.0" }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}
```

```bash
terraform init   # re-init to configure the backend
terraform apply -auto-approve
ls state/        # tfstate file should be here
```""")

    elif 'workspace' in name:
        out.append("""```bash
cd ~/terraform-project
terraform workspace new staging
terraform workspace list   # should show staging
```

Update `main.tf` to use `terraform.workspace`:
```hcl
resource "local_file" "env_config" {
  content  = "environment=${terraform.workspace}\\n"
  filename = "${path.module}/env.conf"
}
```

```bash
terraform apply -auto-approve
cat env.conf   # should show "environment=staging"
```""")

    elif 'modules' in name:
        out.append("""```hcl
# modules/config/main.tf
variable "app_name" { type = string }
variable "environment" { type = string }

resource "local_file" "config" {
  content  = "app=${var.app_name}\\nenv=${var.environment}\\n"
  filename = "${path.module}/app.conf"
}

output "config_path" {
  value = local_file.config.filename
}
```

```hcl
# main.tf
module "app_config" {
  source      = "./modules/config"
  app_name    = "myapp"
  environment = "production"
}
```""")

    elif 'count' in name:
        out.append("""```hcl
variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

resource "local_file" "config" {
  count    = length(var.environments)
  content  = "environment=${var.environments[count.index]}\\n"
  filename = "${path.module}/config-${var.environments[count.index]}.txt"
}
```

```bash
terraform plan   # should show 3 resources
terraform apply -auto-approve
```""")

    elif 'for-each' in name:
        out.append("""```hcl
variable "services" {
  type = map(object({ port = number; env = string }))
  default = {
    web    = { port = 80,   env = "production" }
    api    = { port = 8080, env = "production" }
    worker = { port = 9000, env = "production" }
  }
}

resource "local_file" "service_config" {
  for_each = var.services
  content  = "service=${each.key}\\nport=${each.value.port}\\n"
  filename = "${path.module}/${each.key}.conf"
}
```""")

    elif 'local-values' in name:
        out.append("""```hcl
locals {
  project     = "myapp"
  environment = "production"
  config_content = "project=${local.project}\\nenv=${local.environment}\\n"
}

resource "local_file" "config" {
  content  = local.config_content
  filename = "${path.module}/config.txt"
}
```""")

    elif 'data-sources' in name:
        out.append("""```hcl
data "local_file" "source_config" {
  filename = "${path.module}/source/config.txt"
}

resource "local_file" "combined" {
  content  = data.local_file.source_config.content
  filename = "${path.module}/combined.txt"
}
```""")

    elif 'conditional' in name:
        out.append("""```hcl
variable "environment" { default = "production" }
variable "enable_debug" { default = false }

resource "local_file" "config" {
  content  = "environment=${var.environment}\\n"
  filename = "${path.module}/config.txt"
}

resource "local_file" "debug_log" {
  count    = var.environment != "production" ? 1 : 0
  content  = "debug mode enabled\\n"
  filename = "${path.module}/debug.log"
}
```""")

    elif 'depends-on' in name:
        out.append("""```hcl
resource "null_resource" "create_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/output"
  }
}

resource "local_file" "app_config" {
  content  = "app=myapp\\n"
  filename = "${path.module}/output/app.conf"
  depends_on = [null_resource.create_dir]
}
```""")

    elif 'lifecycle' in name:
        out.append("""```hcl
resource "local_file" "config" {
  content  = "app=myapp\\n"
  filename = "${path.module}/config.txt"
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [content]
  }
}
```""")

    elif 'null-resource' in name:
        out.append("""```hcl
resource "null_resource" "setup" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "echo 'Setup complete' > ${path.module}/setup.log"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/setup.log"
  }
}
```""")

    elif 'provisioners' in name:
        out.append("""```hcl
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/app && echo 'app=myapp' > ${path.module}/app/config.txt"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/app"
  }
}
```""")

    elif 'random-provider' in name:
        out.append("""```hcl
resource "random_pet" "server_name" { length = 2; separator = "-"; prefix = "srv" }
resource "random_integer" "port" { min = 8000; max = 9000 }

resource "local_file" "config" {
  content  = "server=${random_pet.server_name.id}\\nport=${random_integer.port.result}\\n"
  filename = "${path.module}/config.txt"
}
```""")

    elif 'sensitive' in name:
        out.append("""```hcl
variable "db_password" {
  type      = string
  sensitive = true    # redacted in plan/apply output
  default   = "changeme123"
}
variable "api_key" {
  type      = string
  sensitive = true
  default   = "abc123"
}
output "password_set" {
  value     = length(var.db_password) > 0
  sensitive = true
}
```""")

    elif 'splat' in name:
        out.append("""```hcl
resource "random_pet" "servers" { count = 3 }

output "all_server_names" {
  value = random_pet.servers[*].id   # splat: collect .id from all instances
}

resource "local_file" "inventory" {
  content  = join("\\n", random_pet.servers[*].id)
  filename = "${path.module}/inventory.txt"
}
```""")

    elif 'string-interpolation' in name:
        out.append("""```hcl
variable "app_name" { default = "myapp" }
variable "environment" { default = "production" }

locals {
  full_name = "${var.app_name}-${var.environment}"
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\\nenv=${var.environment}\\nfull=${local.full_name}\\n"
  filename = "${path.module}/config.txt"
}
```""")

    elif 'template-file' in name:
        out.append("""```hcl
resource "local_file" "config" {
  content = templatefile("${path.module}/config.tftpl", {
    app_name        = "myapp"
    app_port        = 8080
    app_env         = "production"
    max_connections = 100
    enable_ssl      = false
    ports           = [80, 443, 8080]
  })
  filename = "${path.module}/app.conf"
}
```

`templatefile()` renders a `.tftpl` file with Jinja2-like syntax.""")

    elif 'try-function' in name:
        out.append("""```hcl
variable "config" {
  type    = any
  default = { name = "myapp"; port = 8080; timeout = null }
}

locals {
  app_name = try(var.config.name, "default-app")
  app_port = try(var.config.port, 80)
  timeout  = try(var.config.timeout, 30)
}

resource "local_file" "config" {
  content  = "name=${local.app_name}\\nport=${local.app_port}\\ntimeout=${local.timeout}\\n"
  filename = "${path.module}/config.txt"
}
```

`try()` returns the first expression that doesn't error.""")

    elif 'type-constraints' in name:
        out.append("""```hcl
variable "app_name" {
  type    = string
  default = "myapp"
}
variable "port" {
  type    = number
  default = 8080
}
variable "allowed_hosts" {
  type    = list(string)
  default = ["localhost", "example.com"]
}
variable "feature_flags" {
  type = object({ debug = bool; metrics = bool; tracing = bool })
  default = { debug = false; metrics = true; tracing = false }
}
```""")

    elif 'validation-rules' in name:
        out.append("""```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Must be dev, staging, or production."
  }
}
variable "port" {
  type = number
  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Port must be 1024-65535."
  }
}
variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "Must start with a letter, lowercase letters/numbers/hyphens only."
  }
}
```""")

    elif 'moved-blocks' in name:
        out.append("""```hcl
# Add to main.tf
moved {
  from = local_file.old_config
  to   = local_file.new_config
}

resource "local_file" "new_config" {   # renamed from old_config
  content  = "app=myapp\\n"
  filename = "${path.module}/config.txt"
}
```

```bash
terraform plan   # shows "1 to move, 0 to add, 0 to destroy"
terraform apply -auto-approve
```""")

    elif 'override' in name:
        out.append("""```hcl
# main_override.tf (or any *_override.tf file)
resource "random_pet" "name" {
  length    = 3        # overrides the value in main.tf
  separator = "_"
}
```

Override files are loaded last and merge with the main config.""")

    elif 'drift' in name:
        out.append("""```bash
cd ~/terraform-project

# See what drifted
terraform plan

# Option 1: restore to match Terraform state (overwrites manual change)
terraform apply -auto-approve

# Option 2: update config to match the drift, then apply
```

Terraform detects drift by comparing state against actual files. `apply` reconciles them.""")

    elif 'dynamic-blocks' in name:
        out.append("""```hcl
variable "provisioners" {
  type    = list(string)
  default = ["web", "api", "worker"]
}

resource "local_file" "configs" {
  for_each = toset(var.provisioners)
  content  = "provisioner=${each.value}\\n"
  filename = "${path.module}/${each.value}.conf"
}
```

The validator checks that at least one `dynamic` block exists in your `.tf` files.""")

    else:
        out.append("```bash\ncd ~/terraform-project\nterraform init\nterraform validate\nterraform apply -auto-approve\n```")
        for c in checks:
            if c['fail_msg'] and 'init' not in c['fail_msg'] and 'validate' not in c['fail_msg']:
                out.append(f"\n**Fix:** {c['fail_msg']}")

    return '\n'.join(out)


# ── Generic fallback ────────────────────────────────────────────────────────

def generate_generic(name, data, checks, validate_sh):
    out = ["## What the validator checks\n"]
    for c in checks:
        out.append(f"- {c['fail_msg']}")
    out.append("\n## Solution\n")
    out.append("Address each check above in order:\n")
    for c in checks:
        out.append(f"**{c['fail_msg']}**")
        if c['comment']:
            out.append(f"  → {c['comment']}")
        out.append("")
    return '\n'.join(out)


# ── Entry point ─────────────────────────────────────────────────────────────

def main():
    generated = 0
    errors = 0
    for ch_dir in sorted(CHALLENGES.iterdir()):
        if not ch_dir.is_dir(): continue
        if not (ch_dir / "challenge.yaml").is_file(): continue
        out = ch_dir / "solution.md"
        try:
            content = generate_solution(ch_dir)
            if content:
                out.write_text(content)
                generated += 1
        except Exception as e:
            print(f"ERROR {ch_dir.name}: {e}")
            errors += 1
    print(f"Generated: {generated}  Errors: {errors}")

if __name__ == "__main__":
    main()
