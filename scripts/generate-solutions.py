#!/usr/bin/env python3
"""Generate solution.md for all 165 challenges.
Reads challenge.yaml + validate.sh + starter files to produce accurate solutions.
Run from content repo root: python3 scripts/generate-solutions.py
"""
import os, re, yaml
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CHALLENGES = ROOT / "challenges"

def read(p):
    try: return Path(p).read_text()
    except: return ""

def grep_checks(vs):
    """Extract what validate.sh checks for (grep -q patterns)."""
    return re.findall(r"grep -q ['\"]([^'\"]+)['\"]", vs)

def grep_file_checks(vs):
    """Extract file paths validate.sh checks exist."""
    return re.findall(r"\[ [!-]f ([^\]]+)\]", vs)


# ── Category-specific solution generators ──────────────────────────────────

def solve_linux(name, data, vs, files_dir):
    title = data['name']
    instructions = data.get('instructions', '')
    checks = grep_checks(vs)
    
    lines = [f"# Solution: {title}\n"]
    
    # Derive solution from validate.sh checks
    if 'log-analysis' in name:
        lines.append("""## Approach

Examine the log file, count occurrences of each level, find the most common error, then write a report.

```bash
# Count log levels
ERROR_COUNT=$(grep -c 'ERROR' /var/log/webapp/app.log)
WARN_COUNT=$(grep -c 'WARN' /var/log/webapp/app.log)
INFO_COUNT=$(grep -c 'INFO' /var/log/webapp/app.log)

# Find most common error message
COMMON_ERROR=$(grep 'ERROR' /var/log/webapp/app.log | sort | uniq -c | sort -rn | head -1 | sed 's/^ *[0-9]* *//')

# Write the report
cat > /home/runner/log-analysis.txt << EOF
ERROR count: $ERROR_COUNT
WARN count: $WARN_COUNT
INFO count: $INFO_COUNT
Most common error: $COMMON_ERROR
EOF
```

## Why this works

`grep -c` counts matching lines. `sort | uniq -c | sort -rn` ranks by frequency. The report contains the word "ERROR" and a count, satisfying all validation checks.""")

    elif 'crontab' in name:
        lines.append("""## Approach

Make `backup.sh` executable, add the correct cron entry, and verify the script creates the backup file.

```bash
# Make backup script executable
chmod +x /home/runner/backup.sh

# Add cron job — runs at 2AM daily
(crontab -l 2>/dev/null; echo "0 2 * * * /home/runner/backup.sh") | crontab -

# Verify it was added
crontab -l
```

## Why this works

The cron expression `0 2 * * *` means: minute 0, hour 2, every day, every month, every weekday — i.e. 2:00 AM daily. The validate checks for `^0 2 \* \* \*` at the start of the line.""")

    elif 'compress' in name or 'archive' in name:
        lines.append("""## Approach

Create a gzip-compressed tar archive of the webapp directory.

```bash
tar -czf /home/runner/webapp-backup.tar.gz -C /home/runner webapp/

# Verify contents
tar -tzf /home/runner/webapp-backup.tar.gz
```

## Why this works

`-c` creates, `-z` gzip-compresses, `-f` specifies the output file. `-C /home/runner` changes to that directory first so paths inside the archive are relative (e.g. `webapp/public/index.html` not `/home/runner/webapp/...`).""")

    elif 'symlink' in name:
        lines.append("""## Approach

Fix each broken symlink to point to the correct target in `current/` instead of the deleted `old/` directory.

```bash
# Check which symlinks are broken
ls -la /home/runner/myapp/

# Fix each one
ln -sf /home/runner/myapp/current/config.env /home/runner/myapp/config.env
ln -sf /home/runner/myapp/current/start.sh   /home/runner/myapp/start.sh
ln -sf /home/runner/myapp/current/version.txt /home/runner/myapp/version.txt
ln -sf /home/runner/myapp/current/lib        /home/runner/myapp/lib

# Verify
ls -la /home/runner/myapp/
```

## Why this works

`ln -sf` creates a symbolic link, overwriting any existing one (`-f`). The target must be an absolute path or relative to the symlink's location.""")

    elif 'find-and-replace' in name:
        lines.append("""## Approach

Use `sed` to replace all occurrences of the old hostname with the new one across all config files.

```bash
# Replace in all .conf files
find /home/runner/configs -name "*.conf" -exec sed -i 's/old-server.example.com/new-server.example.com/g' {} +

# Verify
grep -r 'old-server' /home/runner/configs/  # should return nothing
grep -r 'new-server' /home/runner/configs/  # should show all replacements
```

## Why this works

`sed -i` edits files in-place. The `s/old/new/g` substitution replaces all occurrences on each line. `find -exec` applies it to every `.conf` file.""")

    elif 'find-large' in name:
        lines.append("""## Approach

Use `find` to locate files over 100MB and remove them.

```bash
# Find files over 100MB
find / -type f -size +100M 2>/dev/null

# Remove them (after reviewing)
find / -type f -size +100M -delete 2>/dev/null

# Verify none remain
find / -type f -size +100M 2>/dev/null | wc -l
```

## Why this works

`-size +100M` matches files strictly larger than 100 megabytes. The `2>/dev/null` suppresses permission errors on system directories.""")

    elif 'suid' in name:
        lines.append("""## Approach

Find SUID binaries, identify suspicious ones, remove the SUID bit, and write an audit report.

```bash
# Find all SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Remove SUID bit from suspicious binaries (not system ones like sudo, passwd)
chmod u-s /path/to/suspicious/binary

# Write audit report
find / -perm -4000 -type f 2>/dev/null > /home/runner/suid-audit.txt
echo "Suspicious SUID binaries neutralized" >> /home/runner/suid-audit.txt
```

## Why this works

`-perm -4000` matches files with the SUID bit set. `chmod u-s` removes it. Legitimate system SUID binaries (sudo, passwd, ping) should be left alone.""")

    elif 'disk-space' in name or 'manage-disk' in name:
        lines.append("""## Approach

Remove old log files, clean the build cache, and delete old downloads.

```bash
# Remove old log files
find /var/log/myapp -name "*.log.old" -delete

# Clean build cache (keep under 5MB)
rm -rf /tmp/build-cache/*

# Remove old .deb downloads
find /home/runner/downloads -name "*.deb" -delete

# Verify disk usage improved
df -h
```

## Why this works

Each `find -delete` targets exactly what the validation checks for. The build cache check allows up to 5MB, so removing all files satisfies it.""")

    elif 'environment-var' in name:
        lines.append("""## Approach

Add the required environment variables to `~/.bashrc` and source it.

```bash
# Add to .bashrc
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

# Run the app to create the flag file
bash /home/runner/app/start.sh
```

## Why this works

`export` makes variables available to child processes. Sourcing `.bashrc` applies them to the current shell session.""")

    elif 'redirect' in name:
        lines.append("""## Approach

Fix the redirections in `process.sh` — stdout to results file, stderr to errors log, and append (not overwrite) the summary.

```bash
# Edit process.sh to fix redirections
cat > /home/runner/process.sh << 'SCRIPT'
#!/bin/bash
# stdout → results file
echo "Processing started at $(date)" > ~/output/results.txt
echo "Record 1: OK" >> ~/output/results.txt
echo "Record 2: OK" >> ~/output/results.txt
echo "Record 3: OK" >> ~/output/results.txt
echo "Processing complete: 3 records" >> ~/output/results.txt

# stderr → errors log
echo "WARN: Record 4 had missing fields" 2>> ~/output/errors.log
echo "ERROR: Record 5 failed validation" 2>> ~/output/errors.log

# APPEND to summary (not overwrite)
echo "Run completed: $(date) — 3 success, 1 warn, 1 error" >> ~/output/summary.txt
SCRIPT

bash /home/runner/process.sh
```

## Why this works

`>` redirects stdout, `2>` redirects stderr, `>>` appends instead of overwriting.""")

    elif 'kill' in name or 'runaway' in name:
        lines.append("""## Approach

Find the CPU-hogging process and kill it.

```bash
# Find the process
ps aux | grep cpu_hog
# or
pgrep -f cpu_hog

# Kill it
pkill -f cpu_hog

# Verify it's gone
pgrep -f cpu_hog  # should return nothing
```

## Why this works

`pkill -f` matches against the full command line, not just the process name. This reliably kills the background bash script.""")

    elif 'monitor' in name:
        lines.append("""## Approach

Kill the rogue processes and write a system resource report.

```bash
# Kill rogue processes
pkill -f mem_leak
pkill -f cpu_hog2

# Write system report
cat > /home/runner/system-report.txt << EOF
CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')%
Memory: $(free -h | awk '/^Mem:/{print $3 "/" $2}')
Load Average: $(uptime | awk -F'load average:' '{print $2}')
EOF

echo "Rogue processes terminated" >> /home/runner/system-report.txt
```

## Why this works

`pkill -f` kills by command pattern. The report file needs to exist with content — the exact format is flexible.""")

    elif 'recover' in name:
        lines.append("""## Approach

The file was deleted but a process still has it open. Find the file descriptor in `/proc` and copy it out.

```bash
# Find the process holding the deleted file open
lsof | grep config.json
# or
ls /proc/*/fd -la 2>/dev/null | grep config.json

# Get the PID and fd number from the output, then recover
PID=$(lsof | grep config.json | awk '{print $2}' | head -1)
FD=$(lsof -p $PID | grep config.json | awk '{print $4}' | tr -d 'r')

# Copy the file content out
cp /proc/$PID/fd/$FD /home/runner/app/config.json
```

## Why this works

Linux keeps file data alive as long as any process has an open file descriptor, even after `unlink()`. The `/proc/PID/fd/` directory exposes those descriptors as symlinks.""")

    elif 'users' in name or 'groups' in name:
        lines.append("""## Approach

Create the required users, groups, and shared directory with correct permissions.

```bash
# Create group
sudo groupadd developers

# Create users
sudo useradd -m -s /bin/bash alice
sudo useradd -m -s /bin/bash bob

# Add to group
sudo usermod -aG developers alice
sudo usermod -aG developers bob

# Create shared directory
sudo mkdir -p /home/shared
sudo chown root:developers /home/shared
sudo chmod 2775 /home/shared  # setgid so new files inherit group
```

## Why this works

`chmod 2775` sets the setgid bit — new files created in the directory automatically inherit the `developers` group. `775` gives group write access.""")

    elif 'ssh' in name and 'key' in name:
        lines.append("""## Approach

Generate an SSH key pair and configure the correct permissions.

```bash
# Generate key pair (no passphrase for automation)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""

# Set correct permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Add public key to authorized_keys
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Create SSH config
cat > ~/.ssh/config << 'EOF'
Host localhost
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
EOF
chmod 600 ~/.ssh/config
```

## Why this works

SSH enforces strict permission requirements. Private keys must be `600` (owner read/write only). The `.ssh` directory must be `700`.""")

    elif 'ssh' in name and 'config' in name:
        lines.append("""## Approach

Fix the SSH file permissions to match what SSH requires.

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys
```

## Why this works

SSH refuses to use keys with overly permissive permissions. The required permissions are: `.ssh/` → 700, private key → 600, public key → 644, config → 600, authorized_keys → 600 or 644.""")

    elif 'rsync' in name:
        lines.append("""## Approach

Configure and run an rsync backup from source to destination.

```bash
# Create backup destination
mkdir -p /home/runner/backup

# Run rsync backup
rsync -av --delete /home/runner/source/ /home/runner/backup/

# Verify
ls /home/runner/backup/
diff -r /home/runner/source/ /home/runner/backup/
```

## Why this works

`-a` (archive) preserves permissions, timestamps, symlinks. `-v` verbose. `--delete` removes files in destination that no longer exist in source. The trailing `/` on source is important — it copies contents, not the directory itself.""")

    elif 'nfs' in name:
        lines.append("""## Approach

Configure the NFS server, export the share, and mount it.

```bash
# Add export to /etc/exports
echo "/srv/nfs/shared *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

# Apply the export
sudo exportfs -ra

# Start NFS server
sudo service nfs-kernel-server start

# Mount the share locally to test
sudo mount -t nfs localhost:/srv/nfs/shared /mnt/nfs-test

# Verify
ls /mnt/nfs-test/
```

## Why this works

`/etc/exports` defines what directories are shared and to whom. `exportfs -ra` re-reads the file. The `rw` option allows read-write access.""")

    elif 'logrotate' in name:
        lines.append("""## Approach

Create a logrotate configuration file for the application logs.

```bash
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

# Test the configuration
sudo logrotate -d /etc/logrotate.d/myapp
```

## Why this works

`daily` rotates every day, `rotate 7` keeps 7 old logs, `compress` gzips old logs, `missingok` doesn't error if log is missing, `notifempty` skips empty logs.""")

    elif 'swap' in name:
        lines.append("""## Approach

Create a swap file, format it, and enable it permanently.

```bash
# Create a 512MB swap file
sudo dd if=/dev/zero of=/swapfile bs=1M count=512

# Set correct permissions
sudo chmod 600 /swapfile

# Format as swap
sudo mkswap /swapfile

# Enable swap
sudo swapon /swapfile

# Make permanent (add to fstab)
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
sudo swapon --show
free -h
```

## Why this works

`mkswap` formats the file as a swap area. `swapon` activates it. Adding to `/etc/fstab` ensures it persists across reboots.""")

    elif 'lvm' in name:
        lines.append("""## Approach

Extend the LVM logical volume and resize the filesystem.

```bash
# Check current state
sudo lvs
sudo vgs
sudo df -h /mnt/appdata

# Extend the logical volume (use all free space)
sudo lvextend -l +100%FREE /dev/vg_data/lv_app

# Resize the filesystem
sudo resize2fs /dev/vg_data/lv_app

# Verify
sudo lvs
df -h /mnt/appdata
```

## Why this works

`lvextend -l +100%FREE` uses all remaining free space in the volume group. `resize2fs` then expands the ext4 filesystem to fill the new space.""")

    elif 'fstab' in name:
        lines.append("""## Approach

Fix the broken fstab entry and mount the filesystem.

```bash
# View current fstab
cat /etc/fstab

# Remove the broken entry and add the correct one
sudo sed -i '/sdz99/d' /etc/fstab
echo '/opt/disk.img  /mnt/data  ext4  loop  0  0' | sudo tee -a /etc/fstab

# Mount all filesystems from fstab
sudo mount -a

# Verify
mountpoint /mnt/data
df -h /mnt/data
```

## Why this works

The broken entry referenced a non-existent device `/dev/sdz99`. The correct entry uses the loop device option to mount an image file.""")

    elif 'disk-perm' in name:
        lines.append("""## Approach

Fix the mount permissions so the runner user can access the data directory.

```bash
# Check current permissions
ls -la /mnt/data

# Fix ownership and permissions
sudo chown runner:runner /mnt/data
sudo chmod 755 /mnt/data

# Verify
ls -la /mnt/data
touch /mnt/data/test.txt && echo "Write access OK"
```

## Why this works

The directory was created as root-owned with `700` permissions. Changing ownership to `runner` and setting `755` allows the user to read, write, and execute.""")

    elif 'iptables' in name:
        lines.append("""## Approach

Configure iptables rules to allow SSH and HTTP while blocking everything else.

```bash
# Flush existing rules
sudo iptables -F

# Set default policies
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# Allow established connections
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
sudo iptables -A INPUT -i lo -j ACCEPT

# Allow SSH (port 22)
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow HTTP (port 80)
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Verify
sudo iptables -L -n
```

## Why this works

Starting with DROP policy and explicitly allowing only needed ports is the principle of least privilege. The ESTABLISHED rule allows responses to outbound connections.""")

    elif 'network-interface' in name:
        lines.append("""## Approach

Remove the wrong IP and assign the correct one to the dummy interface.

```bash
# Check current state
ip addr show dummy0

# Remove wrong IP
sudo ip addr del 192.168.99.99/24 dev dummy0

# Add correct IP
sudo ip addr add 10.0.0.10/24 dev dummy0

# Bring interface up
sudo ip link set dummy0 up

# Verify
ip addr show dummy0
```

## Why this works

`ip addr del` removes a specific address. `ip addr add` assigns the new one. `ip link set up` ensures the interface is active.""")

    elif 'dns' in name and 'fix' in name:
        lines.append("""## Approach

Replace the broken nameserver with a working public DNS server.

```bash
# View current resolv.conf
cat /etc/resolv.conf

# Fix it
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Test
nslookup google.com
```

## Why this works

`/etc/resolv.conf` controls DNS resolution. The broken nameserver `192.0.2.1` is a documentation IP (RFC 5737) that doesn't respond. Google's `8.8.8.8` is a reliable public resolver.""")

    elif 'apt' in name:
        lines.append("""## Approach

Fix the APT sources list to use a valid mirror and update the package cache.

```bash
# Backup current sources
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

# Fix the sources list
sudo tee /etc/apt/sources.list << 'EOF'
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
EOF

# Update package cache
sudo apt-get update

# Verify
apt-cache show curl | head -5
```

## Why this works

A broken mirror URL or wrong distribution codename causes `apt-get update` to fail. Using the official Ubuntu archive with the correct codename fixes it.""")

    elif 'boot' in name or 'grub' in name:
        lines.append("""## Approach

Edit `/etc/default/grub` to set the correct timeout and kernel parameters.

```bash
# Edit the GRUB configuration
sudo tee /etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOF

# Verify (no need to run update-grub in container)
cat /etc/default/grub
```

## Why this works

`GRUB_TIMEOUT=5` sets a 5-second boot menu timeout. `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"` suppresses verbose boot messages. In a real system you'd run `sudo update-grub` to apply changes.""")

    elif 'locale' in name:
        lines.append("""## Approach

Generate the missing locale and set it as the system default.

```bash
# Generate the locale
sudo locale-gen en_US.UTF-8

# Set as default
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Apply to current session
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Verify
locale
```

## Why this works

`locale-gen` compiles the locale data. `update-locale` writes to `/etc/default/locale`. The export makes it active in the current shell.""")

    elif 'timezone' in name:
        lines.append("""## Approach

Set the system timezone to America/New_York.

```bash
# Set timezone
sudo timedatectl set-timezone America/New_York
# or
sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
echo "America/New_York" | sudo tee /etc/timezone

# Verify
timedatectl
date
```

## Why this works

`/etc/localtime` is a symlink to the timezone data file. `/etc/timezone` stores the timezone name as text. Both need to be consistent.""")

    elif 'selinux' in name:
        lines.append("""## Approach

Fix the SELinux file contexts using `chcon` or `restorecon`.

```bash
# Check current context
ls -Z /srv/www/html/

# Fix context to match httpd content type
sudo chcon -R -t httpd_sys_content_t /srv/www/html/

# Or restore to default policy context
sudo restorecon -Rv /srv/www/html/

# Verify
ls -Z /srv/www/html/
getfattr -n security.selinux /srv/www/html/index.html
```

## Why this works

SELinux uses file contexts to control access. Web server files need the `httpd_sys_content_t` type for nginx/apache to read them. `chcon` changes context directly; `restorecon` uses the policy database.""")

    elif 'sudo' in name and 'configure' in name:
        lines.append("""## Approach

Grant the `developer` user sudo access for specific commands.

```bash
# Create a sudoers drop-in file (safer than editing /etc/sudoers directly)
echo "developer ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/systemctl" | sudo tee /etc/sudoers.d/developer
sudo chmod 0440 /etc/sudoers.d/developer

# Verify syntax
sudo visudo -c -f /etc/sudoers.d/developer

# Test
sudo -l -U developer
```

## Why this works

Drop-in files in `/etc/sudoers.d/` are included by the main sudoers file. `NOPASSWD:` allows running without a password prompt. Always use `visudo -c` to validate syntax before applying.""")

    elif 'systemd' in name or 'service' in name:
        lines.append("""## Approach

Create a valid systemd service unit file for the application.

```bash
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
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Verify the app actually runs
python3 /opt/myapp/server.py &
sleep 2
curl -sf http://localhost:8080
kill %1
```

## Why this works

`[Unit]` describes the service and its dependencies. `[Service]` defines how to run it. `[Install]` controls when it starts at boot. `WantedBy=multi-user.target` enables it for normal multi-user mode.""")

    else:
        # Generic linux solution
        lines.append(f"""## Approach

Review the challenge instructions and the validation checks to understand exactly what's required.

```bash
# Read the instructions carefully
cat ~/README.md 2>/dev/null || true

# Check what validation expects
# The key checks are:
""")
        for check in checks[:5]:
            lines.append(f"# - {check}")
        lines.append("```\n")
        lines.append("""## Key concepts

- Read the error messages carefully — they tell you exactly what's missing
- Use `man <command>` to look up command options
- Test your solution before validating""")

    return "\n".join(lines)


def solve_ansible(name, data, vs, files_dir):
    title = data['name']
    starter = read(files_dir / 'playbook.yml')

    lines = [f"# Solution: {title}\n"]

    if 'copy-module' in name:
        lines.append("""## Approach

The `copy` module has two modes: `src:` (copy a file) and `content:` (write inline text). They are mutually exclusive. Fix each task to use the right one.

```yaml
- name: Copy config from source
  copy:
    src: source_config.txt      # copies the file — db.conf gets "host=localhost"
    dest: /tmp/copymod/db.conf
    mode: "0644"

- name: Create app config with content
  copy:
    content: |                  # inline content
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

## Why this works

`src:` and `content:` are mutually exclusive — using both causes Ansible to fail. The validation checks that `db.conf` contains `host=localhost` (from `source_config.txt`) and `app.conf` contains `name=myapp` (from inline content).""")

    elif 'handlers' in name:
        lines.append("""## Approach

Handlers are tasks that only run when notified. Define them in a `handlers:` section and use `notify:` in tasks.

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

## Why this works

Handlers run once at the end of a play, even if notified multiple times. They only run if the notifying task reports `changed`.""")

    elif 'variables' in name:
        lines.append("""## Approach

Define variables in `vars:` and reference them with `{{ var_name }}` syntax.

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
    - name: Create app directory
      file:
        path: "{{ log_directory }}"
        state: directory

    - name: Create config file
      copy:
        content: |
          [application]
          name={{ app_name }}
          port={{ app_port }}
          env={{ app_env }}
          log_dir={{ log_directory }}
        dest: "{{ log_directory }}/config.ini"
```

## Why this works

Variables defined in `vars:` are scoped to the play. Jinja2 `{{ }}` syntax interpolates them. Paths containing variables must be quoted.""")

    elif 'loops' in name:
        lines.append("""## Approach

Use `loop:` to iterate over a list and create multiple resources.

```yaml
- name: Create app configs
  hosts: local
  become: yes
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
```

## Why this works

`loop:` replaces the deprecated `with_items:`. Each iteration exposes the current item as `item`. For dictionaries, access fields with `item.key`.""")

    elif 'conditionals' in name:
        lines.append("""## Approach

Use `when:` to conditionally execute tasks based on variable values.

```yaml
- name: Configure based on environment
  hosts: local
  become: yes
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

    - name: Create logging config
      copy:
        content: "log_level=INFO\\n"
        dest: /tmp/logging.conf
      when: app_env != "development"
```

## Why this works

`when:` accepts Jinja2 expressions. Note: no `{{ }}` needed in `when:` — Ansible evaluates it as an expression automatically.""")

    elif 'facts' in name:
        lines.append("""## Approach

Use `ansible_facts` to access system information gathered automatically.

```yaml
- name: Gather system info
  hosts: local
  become: yes

  tasks:
    - name: Write system info
      copy:
        content: |
          hostname={{ ansible_hostname }}
          os={{ ansible_distribution }} {{ ansible_distribution_version }}
          kernel={{ ansible_kernel }}
          memory_mb={{ ansible_memtotal_mb }}
          cpu_count={{ ansible_processor_vcpus }}
        dest: /tmp/system_info.txt
```

## Why this works

Ansible automatically runs the `setup` module at the start of each play, populating `ansible_facts`. Access them directly as variables (e.g. `ansible_hostname`) or via `ansible_facts['hostname']`.""")

    elif 'register' in name:
        lines.append("""## Approach

Use `register:` to capture task output and reference it in subsequent tasks.

```yaml
- name: Capture command output
  hosts: local
  become: yes

  tasks:
    - name: Get hostname
      command: hostname
      register: hostname_result

    - name: Get kernel version
      command: uname -r
      register: kernel_result

    - name: Write system report
      copy:
        content: |
          hostname={{ hostname_result.stdout }}
          kernel={{ kernel_result.stdout }}
        dest: /tmp/system_report.txt
```

## Why this works

`register:` stores the full task result as a variable. For `command`/`shell` tasks, `.stdout` contains the output, `.rc` the return code, `.stderr` any errors.""")

    elif 'set-fact' in name:
        lines.append("""## Approach

Use `set_fact:` to create or transform variables during playbook execution.

```yaml
- name: Use set_fact
  hosts: local
  become: yes

  tasks:
    - name: Get current date
      command: date +%Y-%m-%d
      register: date_output

    - name: Set derived facts
      set_fact:
        deploy_date: "{{ date_output.stdout }}"
        app_version: "2.1.0"
        deploy_tag: "v2.1.0-{{ date_output.stdout }}"

    - name: Write deployment info
      copy:
        content: "version={{ app_version }}\\ndate={{ deploy_date }}\\ntag={{ deploy_tag }}\\n"
        dest: /tmp/deploy_info.txt
```

## Why this works

`set_fact:` creates host-scoped variables that persist for the rest of the play. Useful for computed values or transforming registered output.""")

    elif 'tags' in name:
        lines.append("""## Approach

Add `tags:` to tasks to allow selective execution with `--tags` or `--skip-tags`.

```yaml
- name: Deploy application
  hosts: local
  become: yes

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

    - name: Run health check
      command: echo "healthy"
      tags: [health, verify]
```

Run specific tags:
```bash
ansible-playbook -i inventory.ini playbook.yml --tags config
ansible-playbook -i inventory.ini playbook.yml --skip-tags packages
```

## Why this works

Tags let you run subsets of a playbook. A task can have multiple tags. `always` and `never` are special tags.""")

    elif 'lookup' in name:
        lines.append("""## Approach

Use lookup plugins to read data from external sources like files or environment variables.

```yaml
- name: Use lookup plugins
  hosts: local
  become: yes

  tasks:
    - name: Read from file
      copy:
        content: "{{ lookup('file', '/etc/hostname') }}"
        dest: /tmp/hostname.txt

    - name: Read environment variable
      copy:
        content: "path={{ lookup('env', 'PATH') }}\\n"
        dest: /tmp/env_info.txt

    - name: Generate password
      copy:
        content: "token={{ lookup('password', '/tmp/token length=16 chars=ascii_letters,digits') }}\\n"
        dest: /tmp/token.txt
```

## Why this works

Lookup plugins run on the control node (not the target). `lookup('file', path)` reads a local file. `lookup('env', var)` reads an environment variable.""")

    elif 'assert' in name:
        lines.append("""## Approach

Use the `assert` module to validate conditions and fail with clear messages.

```yaml
- name: Validate system requirements
  hosts: local
  become: yes

  tasks:
    - name: Check memory is sufficient
      assert:
        that:
          - ansible_memtotal_mb >= 512
        fail_msg: "Need at least 512MB RAM, got {{ ansible_memtotal_mb }}MB"
        success_msg: "Memory check passed: {{ ansible_memtotal_mb }}MB"

    - name: Check OS is Ubuntu
      assert:
        that:
          - ansible_distribution == "Ubuntu"
        fail_msg: "This playbook requires Ubuntu"

    - name: Write results
      copy:
        content: "assertions passed\\nmemory={{ ansible_memtotal_mb }}MB\\n"
        dest: /tmp/assert_results.txt
```

## Why this works

`assert` fails the play immediately if conditions aren't met, with a clear message. `that:` is a list of Jinja2 expressions that must all be true.""")

    elif 'error' in name:
        lines.append("""## Approach

Use `block`/`rescue`/`always` for structured error handling.

```yaml
- name: Error handling demo
  hosts: local
  become: yes

  tasks:
    - name: Create work directory
      file:
        path: /tmp/errorhandling
        state: directory

    - block:
        - name: Attempt risky operation
          command: cat /tmp/nonexistent_file_12345.txt
          register: file_content

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

## Why this works

`block` groups tasks. `rescue` runs if any block task fails (like try/catch). `always` runs regardless of success or failure (like finally).""")

    elif 'privilege' in name:
        lines.append("""## Approach

Use `become:` and `become_user:` for privilege escalation instead of the deprecated `sudo:`.

```yaml
- name: Privilege escalation demo
  hosts: local
  become: yes          # become root by default

  tasks:
    - name: Create root-owned directory
      file:
        path: /tmp/priv-test
        state: directory
        owner: root
        mode: "0755"

    - name: Write root info
      shell: whoami > /tmp/priv-test/root_user.txt

    - name: Create deploy directory
      file:
        path: /tmp/priv-test/deploy
        state: directory
        owner: deploy
        mode: "0755"

    - name: Write deploy user info
      shell: whoami > /tmp/priv-test/deploy_user.txt
      become_user: deploy    # switch to deploy user for this task
      become: yes

    - name: Write status
      copy:
        content: "privilege escalation configured\\n"
        dest: /tmp/priv-test/status.txt
```

## Why this works

`become: yes` at play level makes all tasks run as root. `become_user: deploy` on a specific task overrides to run as that user. Never use the deprecated `sudo:` directive.""")

    elif 'service' in name:
        lines.append("""## Approach

Use the `command` module to manage the fake service (no systemd in container).

```yaml
- name: Manage application service
  hosts: local
  become: yes

  tasks:
    - name: Create service config directory
      file:
        path: /tmp/myservice-conf
        state: directory

    - name: Write service config
      copy:
        content: |
          [service]
          name=myservice
          port=9090
          workers=4
        dest: /tmp/myservice-conf/service.conf
        mode: "0644"

    - name: Start the service
      command: myservice start
      register: start_result

    - name: Check service status
      command: myservice status
      register: service_status

    - name: Write status to file
      copy:
        content: "{{ service_status.stdout }}\\n"
        dest: /tmp/myservice-conf/status.txt
```

## Why this works

In a container without systemd, use `command:` to run the service script directly. The `myservice` script was created by setup.sh at `/usr/local/bin/myservice`.""")

    elif 'package' in name:
        lines.append("""## Approach

Use the `apt` module with correct state values to install packages.

```yaml
- name: Install required packages
  hosts: local
  become: yes

  tasks:
    - name: Update apt cache
      apt:
        update_cache: yes

    - name: Install curl
      apt:
        name: curl
        state: present      # not "installed" — that's invalid

    - name: Install jq
      apt:
        name: jq
        state: present      # not "latest" unless you want upgrades

    - name: Install tree
      apt:
        name: tree          # use "name:", not "pkg:"
        state: present

    - name: Write version info
      copy:
        content: "packages installed successfully\\n"
        dest: /tmp/packages_installed.txt
```

## Why this works

Valid `state` values for `apt`: `present`, `absent`, `latest`, `build-dep`. `installed` is not valid. Use `name:` not the deprecated `pkg:` alias.""")

    elif 'user' in name:
        lines.append("""## Approach

Use the `user` and `group` modules to manage system users.

```yaml
- name: Manage system users
  hosts: local
  become: yes

  tasks:
    - name: Create deploy group
      group:
        name: deploy
        state: present

    - name: Create deploy user
      user:
        name: deploy        # use "name:", not "username:"
        shell: /bin/bash
        group: deploy
        home: /home/deploy
        create_home: yes
        state: present

    - name: Create appuser
      user:
        name: appuser
        shell: /bin/bash
        groups: deploy
        append: yes
        create_home: yes

    - name: Write user info
      copy:
        content: "users created\\n"
        dest: /tmp/users.txt
```

## Why this works

The correct parameter is `name:`, not `username:`. `groups:` (plural) adds supplementary groups. `append: yes` adds to existing groups rather than replacing them.""")

    elif 'template' in name:
        lines.append("""## Approach

Use the `template` module with a `.j2` file and fix the Jinja2 syntax errors.

First, fix `config.tftpl` → `templates/app.conf.j2`:
```
# Application Configuration
[general]
name = {{ app_name }}
port = {{ app_port }}
environment = {{ app_env }}

[performance]
max_connections = {{ max_connections }}

[security]
{% if enable_ssl %}
ssl_enabled = true
ssl_cert = /etc/ssl/{{ app_name }}.crt
{% else %}
ssl_enabled = false
{% endif %}
```

Then the playbook:
```yaml
- name: Deploy with templates
  hosts: local
  become: yes
  vars:
    app_name: myapp
    app_port: 8080
    app_env: production
    max_connections: 100
    enable_ssl: false

  tasks:
    - name: Deploy config from template
      template:
        src: app.conf.j2
        dest: /tmp/app.conf
        mode: "0644"
```

## Why this works

The original template had `{{ app_name }` (missing closing brace) and `{% if enable_ssl` (missing closing `%}`). The `template` module processes `.j2` files with Jinja2 and writes the result to the destination.""")

    elif 'vault' in name:
        lines.append("""## Approach

Create a vault password file, encrypt secrets with `ansible-vault`, and reference them in the playbook.

```bash
# Create vault password file
echo "mysecretpassword" > ~/.vault_pass
chmod 600 ~/.vault_pass

# Create and encrypt secrets file
ansible-vault create --vault-password-file ~/.vault_pass secrets.yml
# Add: db_password: supersecret123
# Add: api_key: abc123xyz

# Or encrypt an existing file
ansible-vault encrypt --vault-password-file ~/.vault_pass secrets.yml
```

Playbook using vault:
```yaml
- name: Use vault secrets
  hosts: local
  vars_files:
    - secrets.yml

  tasks:
    - name: Write config with secret
      copy:
        content: "db_pass={{ db_password }}\\n"
        dest: /tmp/app-secret.conf
```

Run with vault:
```bash
ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.vault_pass
```

## Why this works

`ansible-vault` encrypts YAML files using AES-256. The vault password file avoids interactive prompts. Never commit unencrypted secrets.""")

    elif 'delegation' in name:
        lines.append("""## Approach

Use `delegate_to:` to run a task on a different host than the current target.

```yaml
- name: Deploy with delegation
  hosts: webservers
  become: yes

  tasks:
    - name: Deploy app config
      copy:
        content: "[app]\\nversion=1.0\\n"
        dest: /tmp/delegation-test/app.conf

    - name: Log deployment to monitoring server
      copy:
        content: "deployed to {{ inventory_hostname }} at {{ ansible_date_time.iso8601 }}\\n"
        dest: /tmp/delegation-test/monitoring.txt
      delegate_to: localhost    # run this task on localhost instead

    - name: Write deploy log
      copy:
        content: "deployment complete\\n"
        dest: /tmp/delegation-test/deploy.log
```

## Why this works

`delegate_to:` redirects a specific task to run on a different host. The task still uses variables from the current host (`inventory_hostname`), but executes on the delegated host.""")

    elif 'serial' in name:
        lines.append("""## Approach

Add `serial:` to the play to control how many hosts are updated at once (rolling deployment).

```yaml
- name: Rolling deployment
  hosts: webservers
  become: yes
  serial: 1          # update 1 host at a time (or use "50%" for percentage)

  tasks:
    - name: Create deploy directory
      file:
        path: /tmp/serial-deploy
        state: directory

    - name: Deploy application
      copy:
        content: |
          version=2.0
          host={{ inventory_hostname }}
        dest: /tmp/serial-deploy/app.conf

    - name: Write deploy marker
      copy:
        content: "deployed\\n"
        dest: /tmp/serial-deploy/deployed.txt
```

## Why this works

`serial: 1` processes one host at a time. `serial: "50%"` does half the hosts at once. This prevents all hosts from being updated simultaneously, enabling zero-downtime deployments.""")

    elif 'roles' in name:
        lines.append("""## Approach

Create a role directory structure and call it from the playbook.

```bash
# Create role structure
mkdir -p ~/ansible-project/roles/webserver/{tasks,handlers,defaults,files}

# roles/webserver/tasks/main.yml
cat > ~/ansible-project/roles/webserver/tasks/main.yml << 'EOF'
- name: Create web directory
  file:
    path: /tmp/webserver
    state: directory

- name: Deploy index
  copy:
    content: "<h1>Hello from role</h1>"
    dest: /tmp/webserver/index.html
EOF

# roles/webserver/defaults/main.yml
cat > ~/ansible-project/roles/webserver/defaults/main.yml << 'EOF'
web_port: 80
web_root: /tmp/webserver
EOF
```

Playbook:
```yaml
- name: Deploy web server
  hosts: local
  become: yes
  roles:
    - webserver
```

## Why this works

Roles provide a structured way to organize tasks, handlers, variables, and files. Ansible automatically loads `tasks/main.yml` when a role is applied.""")

    elif 'callback' in name:
        lines.append("""## Approach

Fix the `ansible.cfg` to configure callback plugins correctly.

```ini
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
```

> Note: In Ansible 2.10+, `callback_whitelist` was renamed to `callbacks_enabled`.

```bash
# Write the fixed config
cat > ~/ansible-project/ansible.cfg << 'EOF'
[defaults]
stdout_callback = yaml
callbacks_enabled = timer, profile_tasks
EOF

# Run the playbook to verify callbacks work
ansible-playbook -i inventory.ini playbook.yml
```

## Why this works

`stdout_callback = yaml` changes output format to YAML (more readable). `callbacks_enabled` activates the timer (shows total time) and profile_tasks (shows per-task timing) plugins.""")

    elif 'inventory' in name:
        lines.append("""## Approach

Fix the inventory syntax and use group variables correctly.

```ini
[webservers]
localhost ansible_connection=local

[dbservers]
localhost ansible_connection=local

[production:children]
webservers
dbservers

[production:vars]
env=production
deploy_user=deploy
```

Key fixes:
- `ansible_connection local` → `ansible_connection=local` (needs `=`)
- `[production:child]` → `[production:children]`
- `[production:var]` → `[production:vars]`

## Why this works

Inventory group syntax requires `=` for variable assignments. `:children` defines a group of groups. `:vars` defines variables for all hosts in a group.""")

    elif 'include' in name or 'import' in name:
        lines.append("""## Approach

Replace deprecated `include:` with `include_tasks:` or `import_tasks:`.

```yaml
- name: Deploy application
  hosts: local
  become: yes
  tasks:
    - import_tasks: tasks/setup_dirs.yml    # static — loaded at parse time
    - include_tasks: tasks/deploy_app.yml   # dynamic — loaded at runtime
```

**Difference:**
- `import_tasks:` — static, processed at playbook parse time. Tags and conditions apply to all tasks inside.
- `include_tasks:` — dynamic, processed at runtime. Can use variables in the filename.

## Why this works

`include:` was deprecated in Ansible 2.4 and removed in 2.8. Use `import_tasks:` for static includes (most common) or `include_tasks:` when you need dynamic file names.""")

    elif 'lineinfile' in name:
        lines.append("""## Approach

Use `lineinfile` to add, modify, or remove specific lines in a file.

```yaml
- name: Manage config lines
  hosts: local
  become: yes

  tasks:
    - name: Ensure config file exists
      file:
        path: /tmp/app.conf
        state: touch

    - name: Set max connections
      lineinfile:
        path: /tmp/app.conf
        regexp: '^max_connections'
        line: 'max_connections = 100'

    - name: Add debug mode
      lineinfile:
        path: /tmp/app.conf
        line: 'debug = false'
        create: yes

    - name: Remove deprecated option
      lineinfile:
        path: /tmp/app.conf
        regexp: '^deprecated_option'
        state: absent
```

## Why this works

`regexp:` matches the line to replace. If no match, the `line:` is appended. `state: absent` removes matching lines. `create: yes` creates the file if it doesn't exist.""")

    elif 'blockinfile' in name:
        lines.append("""## Approach

Use `blockinfile` to insert or update a block of text in a file.

```yaml
- name: Manage config blocks
  hosts: local
  become: yes

  tasks:
    - name: Create config file
      file:
        path: /tmp/nginx.conf
        state: touch

    - name: Add server block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} ANSIBLE MANAGED BLOCK"
        block: |
          server {
              listen 80;
              server_name example.com;
              root /var/www/html;
          }

    - name: Add upstream block
      blockinfile:
        path: /tmp/nginx.conf
        marker: "# {mark} UPSTREAM BLOCK"
        block: |
          upstream backend {
              server 127.0.0.1:8080;
          }
```

## Why this works

`blockinfile` wraps the block with marker comments so it can be identified and updated on subsequent runs. `{mark}` is replaced with `BEGIN` and `END`.""")

    elif 'command' in name and 'shell' in name:
        lines.append("""## Approach

Use `command:` for simple commands and `shell:` only when you need shell features (pipes, redirects, globs).

```yaml
- name: Command vs Shell demo
  hosts: local
  become: yes

  tasks:
    - name: Get hostname (use command — no shell features needed)
      command: hostname
      register: hostname_out

    - name: Write hostname
      copy:
        content: "{{ hostname_out.stdout }}\\n"
        dest: /tmp/cmdshell/hostname.txt

    - name: Get disk usage with pipe (must use shell)
      shell: df -h | grep -v tmpfs | tail -1
      register: disk_out

    - name: Write disk info
      copy:
        content: "{{ disk_out.stdout }}\\n"
        dest: /tmp/cmdshell/disk.txt

    - name: Write summary using shell redirect
      shell: echo "hostname={{ hostname_out.stdout }}" > /tmp/cmdshell/summary.txt
```

## Why this works

`command:` is safer — it doesn't invoke a shell, so no injection risk. `shell:` is needed for pipes (`|`), redirects (`>`), and shell builtins. Prefer `command:` when possible.""")

    elif 'fix-syntax' in name:
        lines.append("""## Approach

Fix the three YAML syntax errors in the playbook.

**Error 1:** Extra indentation on `mode:`
```yaml
# Wrong:
        state: directory
         mode: "0755"   # extra space before mode

# Fixed:
        state: directory
        mode: "0755"
```

**Error 2:** Missing colon after task name
```yaml
# Wrong:
    - name Create config file

# Fixed:
    - name: Create config file
```

**Error 3:** Wrong indentation on file module parameters
```yaml
# Wrong:
    - name: Create log directory
      file:
      path: /tmp/myproject/logs   # should be indented under file:

# Fixed:
    - name: Create log directory
      file:
        path: /tmp/myproject/logs
        state: directory
        mode: "0755"
```

## Why this works

YAML is whitespace-sensitive. Each level of nesting requires consistent indentation (2 spaces is standard for Ansible). Task names require a colon after `name`.""")

    else:
        lines.append(f"""## Approach

Review the playbook and fix the issues so it runs successfully.

```bash
# Check syntax first
ansible-playbook -i inventory.ini playbook.yml --syntax-check

# Run with verbose output to see what's happening
ansible-playbook -i inventory.ini playbook.yml -v
```

## Key concepts

- Always run `--syntax-check` before executing
- Use `-v`, `-vv`, or `-vvv` for increasing verbosity
- Check `failed=0` in the PLAY RECAP to confirm success""")

    return "\n".join(lines)


def solve_docker(name, data, vs, files_dir):
    title = data['name']
    lines = [f"# Solution: {title}\n"]

    if 'build-image' in name:
        lines.append("""## Approach

Create a `Dockerfile` and build the image.

```bash
mkdir -p ~/myapp
cat > ~/myapp/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Hello from myapp" > /app/hello.txt
CMD ["cat", "/app/hello.txt"]
EOF

docker build -t myapp:latest ~/myapp/
docker images | grep myapp
```

## Why this works

`docker build -t name:tag context/` builds an image from a Dockerfile in the given directory. The `-t` flag tags it with a name and version.""")

    elif 'fix-dockerfile' in name:
        lines.append("""## Approach

Fix the errors in the Dockerfile and rebuild.

```bash
cat ~/webapp/Dockerfile  # read the broken file

# Common fixes:
# - Wrong base image name (typo)
# - Missing COPY before RUN
# - Wrong EXPOSE port
# - CMD using wrong syntax

docker build -t webapp:latest ~/webapp/
```

## Why this works

Read the build error carefully — Docker reports the exact line that failed. Fix the syntax, rebuild, and verify the image exists.""")

    elif 'build-args' in name:
        lines.append("""## Approach

Use `ARG` in the Dockerfile and pass values with `--build-arg`.

```dockerfile
FROM alpine:latest
ARG APP_VERSION=1.0.0
ARG APP_ENV=production
RUN echo "version=$APP_VERSION env=$APP_ENV" > /app/config.txt
CMD ["cat", "/app/config.txt"]
```

```bash
docker build -t myapp:latest \
  --build-arg APP_VERSION=2.0.0 \
  --build-arg APP_ENV=staging \
  ~/myapp/
```

## Why this works

`ARG` declares a build-time variable. `--build-arg` passes the value. Unlike `ENV`, `ARG` values are not available in the running container.""")

    elif 'compose' in name:
        lines.append("""## Approach

Fix the two errors in `docker-compose.yml`: the image typo and the indentation.

```yaml
version: "3"
services:
  web:
    image: nginx:alpine      # fix: "ngix" → "nginx"
    ports:
      - "8080:80"
  api:
    image: python:3-alpine   # fix: indentation (was under "web")
    ports:
      - "5000:5000"
    command: python -m http.server 5000
```

```bash
docker compose -f ~/project/docker-compose.yml up -d
docker compose -f ~/project/docker-compose.yml ps
```

## Why this works

The `api` service block was indented under `web`, making it a property of `web` rather than a sibling service. The image name `ngix` was a typo.""")

    elif 'volume' in name:
        lines.append("""## Approach

Run a container with a volume mount to persist data.

```bash
# Create a named volume
docker volume create mydata

# Run container with volume
docker run -d \
  --name databox \
  -v mydata:/data \
  alpine sleep infinity

# Or bind mount a host directory
docker run -d \
  --name databox \
  -v ~/mydata:/data \
  alpine sleep infinity

# Write data and verify persistence
docker exec databox sh -c "echo 'hello' > /data/test.txt"
docker rm -f databox
docker run --rm -v mydata:/data alpine cat /data/test.txt
```

## Why this works

Named volumes persist beyond container lifecycle. Bind mounts link a host directory directly into the container.""")

    elif 'env' in name:
        lines.append("""## Approach

Pass environment variables using `-e` flags or an env file.

```bash
# Using -e flags
docker run -d \
  --name envbox \
  -e APP_ENV=production \
  -e APP_PORT=3000 \
  -e APP_DEBUG=false \
  alpine sleep infinity

# Create env file
cat > ~/app.env << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF

# Run second container with env file
docker run -d \
  --name envbox2 \
  --env-file ~/app.env \
  alpine sleep infinity

# Verify
docker exec envbox env | grep APP_
```

## Why this works

`-e KEY=VALUE` sets individual variables. `--env-file` reads from a file (one `KEY=VALUE` per line). Both are available inside the container via `env`.""")

    elif 'network' in name and 'bridge' in name:
        lines.append("""## Approach

Create a custom bridge network with a specific subnet and run containers on it.

```bash
# Create network with specific subnet
docker network create \
  --driver bridge \
  --subnet 172.20.0.0/16 \
  --gateway 172.20.0.1 \
  appnet

# Run containers on the network with specific IPs
docker run -d \
  --name webhost \
  --network appnet \
  --ip 172.20.0.10 \
  nginx:alpine

docker run -d \
  --name checker \
  --network appnet \
  alpine sleep infinity

# Verify connectivity
docker exec checker ping -c 2 webhost
```

## Why this works

Custom bridge networks provide DNS resolution by container name. `--ip` assigns a static IP within the subnet.""")

    elif 'create-network' in name:
        lines.append("""## Approach

Create a custom network and run containers that can communicate by name.

```bash
docker network create mynet

docker run -d --name web --network mynet nginx:alpine
docker run -d --name tester --network mynet alpine sleep infinity

# Verify DNS resolution
docker exec tester ping -c 2 web
docker exec tester wget -qO- http://web
```

## Why this works

Containers on the same custom network can reach each other by container name. The default bridge network doesn't support this — you need a user-defined network.""")

    elif 'container-networking' in name:
        lines.append("""## Approach

Connect the client container to the web container's network.

```bash
# Check current networks
docker network ls
docker inspect web | grep -A5 Networks

# Connect client to web's network
docker network connect net-web client

# Verify
docker exec client curl -sf http://web:8080
```

## Why this works

The setup put `web` on `net-web` and `client` on `net-client`. Connecting `client` to `net-web` gives it access to `web` by name.""")

    elif 'expose' in name or 'port' in name:
        lines.append("""## Approach

Re-run the container with the correct port mapping.

```bash
# Remove the existing container
docker rm -f webserver

# Run with port mapping
docker run -d \
  --name webserver \
  -p 8080:80 \
  nginx:alpine

# Verify
curl http://localhost:8080
```

## Why this works

`-p host_port:container_port` maps a port on the host to a port inside the container. Without `-p`, the container port is only accessible from within Docker networks.""")

    elif 'exec' in name:
        lines.append("""## Approach

Use `docker exec` to run commands inside a running container.

```bash
# Run an interactive shell
docker exec -it workbox sh

# Run a single command
docker exec workbox ls /

# Run as a specific user
docker exec -u root workbox whoami

# Create a file inside the container
docker exec workbox sh -c "echo 'hello' > /tmp/test.txt"
docker exec workbox cat /tmp/test.txt
```

## Why this works

`docker exec` runs a command in a running container. `-it` allocates a pseudo-TTY and keeps stdin open for interactive use. `-u` specifies the user.""")

    elif 'copy' in name and 'file' in name:
        lines.append("""## Approach

Use `docker cp` to copy files between host and container in both directions.

```bash
# Copy FROM container TO host
docker cp filebox:/var/log/app.log ~/extracted.log

# Create a file to inject
echo "mode=active" > ~/inject.conf

# Copy FROM host TO container
docker cp ~/inject.conf filebox:/etc/inject.conf

# Verify
cat ~/extracted.log
docker exec filebox cat /etc/inject.conf
```

## Why this works

`docker cp src dest` copies files. Use `container:/path` syntax for container paths. Works for both running and stopped containers.""")

    elif 'inspect' in name:
        lines.append("""## Approach

Use `docker inspect` to extract container metadata and write a report.

```bash
# Get all info
docker inspect mystery

# Extract specific fields
IP=$(docker inspect mystery --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}')
IMAGE=$(docker inspect mystery --format '{{.Config.Image}}')
HOSTNAME=$(docker inspect mystery --format '{{.Config.Hostname}}')
PORTS=$(docker inspect mystery --format '{{json .NetworkSettings.Ports}}')

# Write report
cat > ~/report.txt << EOF
Container: mystery
IP Address: $IP
Image: $IMAGE
Hostname: $HOSTNAME
Ports: $PORTS
EOF
```

## Why this works

`docker inspect` returns JSON. `--format` uses Go templates to extract specific fields. `{{range}}` iterates over maps/slices.""")

    elif 'logs' in name:
        lines.append("""## Approach

Use `docker logs` to find the failing container and extract the error.

```bash
# Check logs for each container
docker logs app1
docker logs app2
docker logs app3

# Find the one with errors
docker logs app2 2>&1 | grep ERROR

# Write the report
CONTAINER="app2"
ERROR=$(docker logs $CONTAINER 2>&1 | grep ERROR | head -1)

cat > ~/error-report.txt << EOF
$CONTAINER
$ERROR
EOF
```

## Why this works

`docker logs` shows stdout and stderr from a container. `2>&1` merges stderr into stdout for piping. The report needs the container name on line 1 and the error on line 2.""")

    elif 'restart' in name:
        lines.append("""## Approach

Run containers with different restart policies.

```bash
# always: restart regardless of exit code
docker run -d --name always-up --restart always alpine sleep infinity

# on-failure with max retries
docker run -d --name on-fail --restart on-failure:3 alpine sleep infinity

# unless-stopped: restart unless manually stopped
docker run -d --name unless-manual --restart unless-stopped alpine sleep infinity

# Verify policies
docker inspect always-up --format '{{.HostConfig.RestartPolicy.Name}}'
docker inspect on-fail --format '{{.HostConfig.RestartPolicy.MaximumRetryCount}}'
```

## Why this works

Restart policies control what Docker does when a container exits. `always` restarts even after `docker stop`. `unless-stopped` doesn't restart after a manual stop.""")

    elif 'healthcheck' in name:
        lines.append("""## Approach

Run a container with a `HEALTHCHECK` configured.

```bash
docker run -d \
  --name healthyweb \
  --health-cmd "wget -qO- http://localhost/ || exit 1" \
  --health-interval 10s \
  --health-timeout 5s \
  --health-retries 3 \
  nginx:alpine

# Wait for health check to run
sleep 15

# Check health status
docker inspect healthyweb --format '{{.State.Health.Status}}'
```

## Why this works

`--health-cmd` runs periodically inside the container. Exit 0 = healthy, exit 1 = unhealthy. Docker marks the container status accordingly.""")

    elif 'resource' in name and 'limit' in name:
        lines.append("""## Approach

Run a container with memory and CPU limits.

```bash
docker run -d \
  --name limited \
  --memory 128m \
  --cpus 0.5 \
  nginx:alpine

# Verify limits
docker inspect limited --format '{{.HostConfig.Memory}}'      # 134217728 (128MB in bytes)
docker inspect limited --format '{{.HostConfig.NanoCpus}}'    # 500000000 (0.5 CPUs)
```

## Why this works

`--memory` sets a hard memory limit. `--cpus` limits CPU usage as a fraction of one core. These prevent a single container from starving other processes.""")

    elif 'multi-stage' in name:
        lines.append("""## Approach

Use a multi-stage build to compile in one stage and copy only the binary to a minimal final image.

```dockerfile
# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o server .

# Stage 2: minimal runtime image
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

## Why this works

The Go toolchain (~300MB) is only in the builder stage. The final image only contains the compiled binary and Alpine (~5MB). `COPY --from=builder` copies across stages.""")

    elif 'image-layers' in name:
        lines.append("""## Approach

Optimize the Dockerfile to minimize layer count and image size.

```dockerfile
# Bloated (each RUN creates a layer, apt cache not cleaned)
FROM ubuntu:22.04
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN rm -rf /var/lib/apt/lists/*

# Optimized (single RUN, cache cleaned in same layer)
FROM ubuntu:22.04
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl wget && \
    rm -rf /var/lib/apt/lists/*
```

```bash
docker build -t bloated:latest -f Dockerfile.bloated .
docker build -t optimized:latest -f Dockerfile.optimized .
docker images | grep -E 'bloated|optimized'
```

## Why this works

Each `RUN` instruction creates a new layer. Combining commands with `&&` reduces layers. Cleaning apt cache in the same `RUN` actually removes it (cleaning in a later layer doesn't reduce size).""")

    elif 'save' in name or 'load' in name:
        lines.append("""## Approach

Save an image to a tar file and load it back with a new tag.

```bash
# Build or pull the source image
docker pull alpine:latest
docker tag alpine:latest savetest:v1

# Save to tar
docker save savetest:v1 -o ~/savetest.tar

# Remove original (simulate transfer)
docker rmi savetest:v1

# Load from tar
docker load -i ~/savetest.tar

# Tag as restored
docker tag savetest:v1 restored:v1

# Verify it runs
docker run --rm restored:v1 echo "save test"
```

## Why this works

`docker save` exports an image with all its layers and metadata. `docker load` imports it. This is how you transfer images without a registry.""")

    elif 'tag' in name:
        lines.append("""## Approach

Build an image and apply multiple tags to it.

```bash
# Build the base image
docker build -t tagme:v1.0 ~/myapp/

# Add additional tags (all point to same image ID)
docker tag tagme:v1.0 tagme:v1.0.0
docker tag tagme:v1.0 myregistry/tagme:v1.0

# Verify all tags exist
docker images | grep tagme
```

## Why this works

`docker tag` creates an alias — all tags point to the same image layers. No data is duplicated. This is how you prepare an image for pushing to different registries.""")

    elif 'prune' in name:
        lines.append("""## Approach

Remove stopped containers, unused networks, and dangling images.

```bash
# Remove specific stopped containers
docker rm old1 old2 old3

# Or remove all stopped containers
docker container prune -f

# Remove unused networks
docker network rm unused-net1 unused-net2
# Or remove all unused networks
docker network prune -f

# Remove dangling images (untagged)
docker image prune -f

# Nuclear option — remove everything unused
docker system prune -f

# Verify
docker ps -a --filter status=exited
docker network ls
```

## Why this works

`docker prune` commands remove unused resources. `-f` skips the confirmation prompt. `docker system prune` combines container, network, and image cleanup.""")

    elif 'overlay' in name:
        lines.append("""## Approach

Initialize Docker Swarm and create an overlay network with a service.

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create --driver overlay --attachable myoverlay

# Deploy a service on the overlay network
docker service create \
  --name web-service \
  --network myoverlay \
  --replicas 2 \
  nginx:alpine

# Verify
docker network ls | grep overlay
docker service ls
```

## Why this works

Overlay networks span multiple Docker hosts in a swarm. `--attachable` allows standalone containers to connect. Services on the same overlay network can communicate by service name.""")

    elif 'fix-build-context' in name:
        lines.append("""## Approach

Create a `.dockerignore` file to exclude large directories from the build context.

```bash
cat > ~/bigproject/.dockerignore << 'EOF'
data/
node_modules/
*.log
.git/
tmp/
EOF

# Build the optimized image
docker build -t slim-project:latest ~/bigproject/

# Verify excluded files aren't in the image
docker run --rm slim-project:latest ls /app/
```

## Why this works

`.dockerignore` works like `.gitignore` — it prevents files from being sent to the Docker daemon as build context. Large `node_modules/` or `data/` directories can make builds slow and images bloated.""")

    elif 'fix-dns' in name:
        lines.append("""## Approach

Re-run the container with a working DNS server.

```bash
# Remove the broken container
docker rm -f dnsbox

# Run with correct DNS
docker run -d \
  --name dnsbox-fixed \
  --dns 8.8.8.8 \
  alpine sleep infinity

# Verify DNS works
docker exec dnsbox-fixed nslookup google.com
```

## Why this works

`--dns` overrides the DNS server for the container. The broken container used `192.0.2.1` (a documentation IP that doesn't respond). Google's `8.8.8.8` is a reliable public resolver.""")

    elif 'fix-entrypoint' in name:
        lines.append("""## Approach

Fix the typo in the Dockerfile and change to exec form entrypoint.

```dockerfile
FROM python:3-alpine
WORKDIR /app
COPY app.py .
# Fix 1: "pythonn" → "python3"
# Fix 2: use exec form (JSON array) not shell form
ENTRYPOINT ["python3", "app.py"]
```

```bash
docker build -t fixed-server:latest ~/server/
docker run -d --name myserver fixed-server:latest
docker ps | grep myserver
```

## Why this works

Shell form (`ENTRYPOINT python3 app.py`) runs via `/bin/sh -c`, which means PID 1 is the shell, not your app. Exec form (`["python3", "app.py"]`) makes your app PID 1, enabling proper signal handling.""")

    elif 'fix-permissions' in name:
        lines.append("""## Approach

Fix the Dockerfile to create a non-root user and set correct directory permissions.

```dockerfile
FROM alpine:latest
RUN adduser -D -u 1001 appuser && \
    mkdir -p /app/data && \
    chown -R appuser:appuser /app
USER appuser
WORKDIR /app
CMD ["sh", "-c", "while true; do sleep 1; done"]
```

```bash
docker build -t fixed-app:latest ~/app/
docker run -d --name permbox fixed-app:latest
docker exec permbox id
docker exec permbox test -w /app/data && echo "writable"
```

## Why this works

Running as non-root reduces attack surface. The `chown` must happen before `USER` (while still root). `/app/data` needs to be owned by the app user to be writable.""")

    elif 'fix-storage' in name:
        lines.append("""## Approach

Fix the container to use the correct user ID and add tmpfs for writable paths.

```bash
docker rm -f storebox

docker run -d \
  --name storebox \
  -v ~/storage:/data \
  -u $(id -u):$(id -g) \
  --tmpfs /tmp \
  alpine sleep infinity

# Verify
docker exec storebox id
docker exec storebox touch /tmp/test.txt && echo "tmpfs writable"
```

## Why this works

`-u $(id -u):$(id -g)` runs the container as your current user, matching the volume mount ownership. `--tmpfs` mounts a temporary in-memory filesystem for paths that need to be writable.""")

    elif 'debug' in name or 'crashed' in name:
        lines.append("""## Approach

Inspect the crashed container's logs and exit code to diagnose the issue.

```bash
# Check container status
docker ps -a | grep webapp

# Read the logs
docker logs webapp

# Check exit code
docker inspect webapp --format '{{.State.ExitCode}}'

# Start a new container with the same image to debug interactively
docker run -it --rm --entrypoint sh $(docker inspect webapp --format '{{.Config.Image}}')

# Fix the issue (e.g., missing file, wrong command)
# Then restart
docker start webapp
```

## Why this works

`docker logs` shows stdout/stderr even from stopped containers. The exit code tells you how it failed (1 = general error, 126 = permission denied, 127 = command not found).""")

    elif 'linking' in name:
        lines.append("""## Approach

Use `--link` to connect containers (legacy feature).

```bash
# Start the redis server
docker run -d --name redis-server redis:alpine

# Link the client to the server using an alias
docker run -d \
  --name redis-client \
  --link redis-server:db \
  alpine sleep infinity

# Verify the link works (db resolves to redis-server's IP)
docker exec redis-client ping -c 2 db
```

## Why this works

`--link source:alias` adds the source container's IP to the client's `/etc/hosts` under the alias name. Note: `--link` is legacy — prefer custom networks for new projects.""")

    elif 'read-only' in name:
        lines.append("""## Approach

Run nginx with a read-only root filesystem and tmpfs for writable paths.

```bash
docker run -d \
  --name readonly-web \
  --read-only \
  --tmpfs /var/cache/nginx \
  --tmpfs /var/run \
  --tmpfs /tmp \
  nginx:alpine

# Verify read-only
docker exec readonly-web touch /test.txt 2>&1  # should fail
docker exec readonly-web touch /tmp/test.txt   # should succeed (tmpfs)
```

## Why this works

`--read-only` makes the root filesystem immutable. nginx needs to write to `/var/cache/nginx` and `/var/run` — `--tmpfs` mounts in-memory filesystems at those paths.""")

    elif 'tmpfs' in name:
        lines.append("""## Approach

Mount tmpfs filesystems for in-memory storage.

```bash
# Container with tmpfs cache
docker run -d \
  --name tmpbox \
  --tmpfs /app/cache:size=64m \
  alpine sleep infinity

# Container with secure tmpfs (no exec, no suid)
docker run -d \
  --name securebox \
  --tmpfs /run/secrets:noexec,nosuid,size=32m \
  alpine sleep infinity

# Verify
docker inspect tmpbox --format '{{json .HostConfig.Tmpfs}}'
```

## Why this works

`--tmpfs` mounts a temporary in-memory filesystem. Data is lost when the container stops. Options like `noexec` and `nosuid` add security constraints.""")

    elif 'user-namespace' in name:
        lines.append("""## Approach

Fix the Dockerfile to add a non-root user with UID 1001.

```dockerfile
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh && \
    adduser -D -u 1001 appuser
USER appuser
CMD ["./app.sh"]
```

```bash
docker build -t safebox:latest ~/nonroot/
docker run -d --name safebox safebox:latest sleep infinity
docker exec safebox id -u  # should return 1001
```

## Why this works

`adduser -D -u 1001 appuser` creates a user with UID 1001. `USER appuser` switches to that user for all subsequent instructions and the container runtime.""")

    elif 'signal' in name:
        lines.append("""## Approach

Fix the Dockerfile to use exec form entrypoint so signals reach the process.

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
# Should show: [python3 app.py] — not [/bin/sh -c python3 app.py]
```

## Why this works

Shell form wraps the command in `/bin/sh -c`, making the shell PID 1. Signals like SIGTERM go to the shell, not your app. Exec form makes your app PID 1 directly.""")

    elif 'init' in name:
        lines.append("""## Approach

Run the container with the `--init` flag to use Docker's init process as PID 1.

```bash
docker run -d --name with-init --init alpine sleep infinity

# Verify PID 1 is an init process
docker exec with-init ps -o comm= -p 1  # should show "init" or "tini"
```

## Why this works

`--init` injects `tini` as PID 1. This properly handles zombie processes (reaping orphaned children) and forwards signals to child processes — something a naive `sleep infinity` or app process doesn't do.""")

    else:
        lines.append("""## Approach

```bash
# Check what the validation expects
# Run docker commands to satisfy the requirements
docker ps -a
docker images
```

## Key concepts

- Use `docker ps -a` to see all containers (including stopped)
- Use `docker images` to see all images
- Use `docker inspect <name>` to get detailed container/image info
- Check `docker logs <name>` for container output""")

    return "\n".join(lines)


def solve_k8s(name, data, vs, files_dir):
    title = data['name']
    lines = [f"# Solution: {title}\n"]
    checks = grep_checks(vs)

    if 'create-deployment' in name:
        lines.append("""## Solution

```yaml
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

## Why this works

A Deployment needs `spec.selector.matchLabels` to match `spec.template.metadata.labels` — this is how it knows which Pods belong to it. The `replicas: 3` creates 3 identical Pods.""")

    elif 'create-service' in name or 'fix-service' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

## Why this works

`selector` must match the Pod labels exactly. `port` is what clients connect to; `targetPort` is the container port. Both must be integers (not strings).""")

    elif 'create-secret' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_USER: YWRtaW4=        # base64("admin")
  DB_PASS: c3VwZXJzZWNyZXQ=  # base64("supersecret")
```

```yaml
# Pod using the secret
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_USER
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_PASS
    command: ["sleep", "infinity"]
```

```bash
# Encode values
echo -n "admin" | base64
echo -n "supersecret" | base64
```

## Why this works

Secret values must be base64-encoded in the YAML. `secretKeyRef` injects them as environment variables.""")

    elif 'fix-volume' in name:
        lines.append("""## Solution

The volume names in `volumeMounts` must exactly match the names in `volumes`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: config-vol      # must match volumes[].name below
      mountPath: /etc/config
    - name: data-vol        # must match volumes[].name below
      mountPath: /data
  volumes:
  - name: config-vol        # matches volumeMounts[0].name
    configMap:
      name: app-config
  - name: data-vol          # matches volumeMounts[1].name
    emptyDir: {}
```

## Why this works

`volumeMounts[].name` is a reference to `volumes[].name`. A mismatch causes the Pod to fail with `MountVolume.SetUp failed`.""")

    elif 'fix-configmap' in name:
        lines.append("""## Solution

ConfigMap values must be strings. Wrap numbers in quotes.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "localhost"
  DATABASE_PORT: "5432"      # must be a string, not integer 5432
  MAX_CONNECTIONS: "100"     # must be a string, not integer 100
  APP_ENV: "production"
```

```yaml
# Pod referencing the ConfigMap
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: alpine
    envFrom:
    - configMapRef:
        name: app-config    # must match ConfigMap name above
    command: ["sleep", "infinity"]
```

## Why this works

YAML integers are not strings. `DATABASE_PORT: 5432` is an integer; `DATABASE_PORT: "5432"` is a string. Kubernetes ConfigMap values must be strings.""")

    elif 'fix-labels' in name or 'fix-selector' in name:
        lines.append("""## Solution

The Deployment's `matchLabels` and Service's `selector` must both match the Pod template labels.

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-server      # must match template labels
  template:
    metadata:
      labels:
        app: api-server    # this is what Pods get
    spec:
      containers:
      - name: api
        image: nginx:alpine
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api-server        # must match Pod labels
  ports:
  - port: 80
    targetPort: 8080
```

## Why this works

Labels are the glue in Kubernetes. The Deployment uses `matchLabels` to find its Pods. The Service uses `selector` to find Pods to route traffic to. All three must be identical.""")

    elif 'fix-rbac' in name:
        lines.append("""## Solution

```yaml
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
```

```yaml
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
  name: pod-reader     # must match the Role name above
  apiGroup: rbac.authorization.k8s.io
```

## Why this works

`roleRef.kind` must be `Role` (not `ClusterRole`) when binding to a namespace-scoped Role. `roleRef.name` must exactly match the Role's `metadata.name`.""")

    elif 'fix-hpa' in name:
        lines.append("""## Solution

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment      # must be "Deployment" not "deployment"
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
```

## Why this works

`scaleTargetRef.kind` is case-sensitive — must be `Deployment`. `minReplicas: 2` and `maxReplicas: 10` are the required values. Use `autoscaling/v2` (not the deprecated `v1`).""")

    elif 'fix-ingress' in name:
        lines.append("""## Solution

```yaml
apiVersion: networking.k8s.io/v1    # not extensions/v1beta1
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
```

## Why this works

`extensions/v1beta1` Ingress was removed in Kubernetes 1.22. The new `networking.k8s.io/v1` API requires `pathType` and uses a nested `service:` block instead of flat `serviceName`/`servicePort` fields.""")

    elif 'fix-network-policy' in name:
        lines.append("""## Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
spec:
  podSelector:
    matchLabels:
      app: api           # target the api pods
  policyTypes:
  - Ingress
  - Egress              # must include Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend  # only allow from frontend
    ports:
    - port: 8080
  egress:               # allow all egress (empty = allow all)
  - {}
```

## Why this works

Including `Egress` in `policyTypes` without an `egress:` rule would block all outbound traffic. An empty `egress: [{}]` allows all egress while still declaring the policy type.""")

    elif 'fix-pvc' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi      # not "cpu" — PVCs request storage, not CPU
```

## Why this works

PVCs request `storage`, not `cpu` or `memory`. Those belong in Pod resource requests. `ReadWriteOnce` means one node can mount it read-write at a time.""")

    elif 'fix-statefulset' in name:
        lines.append("""## Solution

Two fixes needed: add `clusterIP: None` to the Service (headless) and add `serviceName` to the StatefulSet.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None        # headless service — required for StatefulSet DNS
  selector:
    app: postgres
  ports:
  - port: 5432
```

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless   # must reference the headless service
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
```

## Why this works

StatefulSets require a headless Service (`clusterIP: None`) for stable DNS names (`pod-0.service.namespace.svc.cluster.local`). The `serviceName` field links them.""")

    elif 'fix-tolerations' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

Tolerations must match the taint exactly: same `key`, `value`, and `effect`. `operator: Equal` requires a value match. `operator: Exists` matches any value for that key.""")

    elif 'fix-node-selector' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disktype: ssd        # must match node label exactly
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

`nodeSelector` is a simple key-value match against node labels. The node must have the exact label for the Pod to be scheduled there. Use `kubectl get nodes --show-labels` to see available labels.""")

    elif 'fix-pod-security' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
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
```

## Why this works

`runAsNonRoot: true` prevents running as root. `allowPrivilegeEscalation: false` prevents gaining more privileges. `capabilities: drop: ALL` removes all Linux capabilities. These are Pod Security Standards best practices.""")

    elif 'fix-env-vars' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: APP_ENV
      value: "production"
    - name: APP_PORT
      value: "8080"        # must be string, not integer
    - name: DB_HOST
      value: "localhost"
    command: ["sleep", "infinity"]
```

## Why this works

Environment variable values in Kubernetes must be strings. `value: 8080` (integer) causes a validation error — use `value: "8080"` (quoted string).""")

    elif 'fix-dns' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-pod
spec:
  dnsPolicy: ClusterFirst    # not "None" without dnsConfig
  containers:
  - name: app
    image: alpine
    command: ["sleep", "infinity"]
```

## Why this works

`dnsPolicy: None` requires a `dnsConfig` block with explicit nameservers. `ClusterFirst` uses the cluster DNS (CoreDNS) which resolves both cluster-internal names and external names.""")

    elif 'fix-image-pull' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-pod
spec:
  containers:
  - name: app
    image: nginx:1.25        # fix: use a valid, accessible image tag
    imagePullPolicy: IfNotPresent
```

## Why this works

`imagePullPolicy: Always` forces a pull every time, which fails if the registry is unreachable. `IfNotPresent` uses the cached image if available. Also ensure the image name and tag are correct — a typo causes `ImagePullBackOff`.""")

    elif 'fix-container-port' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: port-pod
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80      # integer, not string "80"
---
apiVersion: v1
kind: Service
metadata:
  name: port-service
spec:
  selector:
    app: port-pod
  ports:
  - port: 80
    targetPort: 80           # must match containerPort
```

## Why this works

`containerPort` must be an integer. The Service `targetPort` must match the container's actual listening port.""")

    elif 'crashlooping' in name:
        lines.append("""## Solution

Fix the invalid command in the Pod manifest and re-apply it.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: nginx:alpine
    # Option 1: remove the command entirely (use image default)
    ports:
    - containerPort: 80
```

Or keep a command but use the correct binary:
```yaml
    command: ["nginx", "-g", "daemon off;"]
```

```bash
# Apply the fix
kubectl apply -f ~/pod.yaml

# Watch it come up
kubectl get pod web-app -w
```

## Why this works

`nginx-wrong` doesn't exist in the image, causing `exec format error` and immediate crash. Removing `command:` lets nginx use its default entrypoint. The Pod transitions from `CrashLoopBackOff` to `Running`.""")

    elif 'init-containers' in name:
        lines.append("""## Solution

```yaml
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

## Why this works

Init containers run to completion before app containers start. They share volumes with app containers. Use them for setup tasks: waiting for dependencies, seeding data, or running migrations.""")

    elif 'liveness' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
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
```

## Why this works

`livenessProbe` restarts the container if it fails. `readinessProbe` removes the Pod from Service endpoints if it fails. `initialDelaySeconds` prevents false failures during startup.""")

    elif 'multi-container' in name:
        lines.append("""## Solution

```yaml
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
```

## Why this works

Containers in the same Pod share the same network namespace (same IP) and can share volumes. The `emptyDir` volume is created when the Pod starts and deleted when it stops.""")

    elif 'resource-limits' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
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

## Why this works

`requests` is what the scheduler uses to find a node with enough capacity. `limits` is the hard cap — exceeding memory causes OOMKill; exceeding CPU causes throttling. `100m` = 0.1 CPU cores.""")

    elif 'rolling-update' in name:
        lines.append("""## Solution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 10
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
```

## Why this works

`maxSurge: 1` allows one extra Pod during the update. `maxUnavailable: 1` allows one Pod to be down. `minReadySeconds: 10` waits 10s after a Pod is ready before continuing the rollout.""")

    elif 'sidecar' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
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
      readOnly: true        # sidecar only reads logs
  volumes:
  - name: log-volume
    emptyDir: {}
```

## Why this works

The sidecar pattern uses a second container to augment the main container. Sharing a volume lets the log-shipper read logs written by nginx. `readOnly: true` prevents accidental writes.""")

    elif 'create-namespace' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    env: staging
    team: backend
  annotations:
    description: "Staging environment for backend team"
```

```bash
kubectl apply --dry-run=server -f ~/namespace.yaml
```

## Why this works

Namespaces provide isolation between environments. Labels enable filtering and policy enforcement. Annotations store non-identifying metadata.""")

    elif 'create-job' in name:
        lines.append("""## Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  completions: 1
  parallelism: 1
  template:
    spec:
      restartPolicy: Never    # required for Jobs (not Always)
      containers:
      - name: processor
        image: alpine
        command: ["sh", "-c", "echo 'processing data' && sleep 5 && echo 'done'"]
```

## Why this works

Jobs run to completion (unlike Deployments which run forever). `restartPolicy: Never` or `OnFailure` are the only valid values for Jobs. `completions` sets how many successful runs are needed.""")

    elif 'create-cronjob' in name:
        lines.append("""## Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"      # 2AM daily
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
```

## Why this works

CronJob schedule uses standard cron syntax. `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` control how many completed Jobs are kept for debugging.""")

    elif 'create-daemonset' in name:
        lines.append("""## Solution

```yaml
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
        command: ["sh", "-c", "while true; do echo 'collecting logs'; sleep 60; done"]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

## Why this works

DaemonSets run exactly one Pod per node. They're used for node-level agents: log collectors, monitoring, network plugins. `hostPath` mounts the node's filesystem into the container.""")

    elif 'create-pdb' in name:
        lines.append("""## Solution

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2           # or use maxUnavailable: 1
  selector:
    matchLabels:
      app: web-app
```

```yaml
# Deployment with enough replicas
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 4               # must be > minAvailable
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
```

## Why this works

PDBs prevent too many Pods from being disrupted simultaneously during voluntary disruptions (node drains, rolling updates). `minAvailable: 2` ensures at least 2 Pods are always running.""")

    elif 'create-limit-range' in name:
        lines.append("""## Solution

```yaml
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
    min:
      cpu: "50m"
      memory: "64Mi"
```

## Why this works

LimitRange sets default resource requests/limits for containers that don't specify them. `default` is applied as the limit; `defaultRequest` as the request. `max`/`min` enforce boundaries.""")

    elif 'create-resource-quota' in name:
        lines.append("""## Solution

```yaml
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
    persistentvolumeclaims: "5"
```

## Why this works

ResourceQuota limits total resource consumption in a namespace. `requests.*` limits what can be requested; `limits.*` limits the hard caps. `pods`, `services` limit object counts.""")

    elif 'create-priority-class' in name:
        lines.append("""## Solution

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority workloads"
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: priority-pod
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

Higher `value` means higher priority. When resources are scarce, the scheduler preempts lower-priority Pods to make room for higher-priority ones. `globalDefault: false` means it's not applied to all Pods automatically.""")

    elif 'create-service-account' in name:
        lines.append("""## Solution

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: app-sa
  namespace: default
```

```yaml
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
  name: edit              # built-in role with edit permissions
  apiGroup: rbac.authorization.k8s.io
```

## Why this works

ServiceAccounts provide an identity for Pods. RoleBindings grant permissions. The built-in `edit` ClusterRole allows creating/updating/deleting most resources in a namespace.""")

    else:
        lines.append(f"""## Approach

```bash
# Examine the broken manifest
cat ~/pod.yaml  # or deployment.yaml, service.yaml, etc.

# Check what validation expects
kubectl apply --dry-run=server -f ~/manifest.yaml

# Fix the issues and re-validate
```

## Key concepts

- Read the error message from `kubectl apply` carefully
- Check `apiVersion` matches the resource kind
- Verify all required fields are present
- Ensure label selectors match across resources""")

    return "\n".join(lines)


def solve_terraform(name, data, vs, files_dir):
    title = data['name']
    lines = [f"# Solution: {title}\n"]

    if 'fix-syntax' in name:
        lines.append("""## Approach

Fix the HCL syntax error (missing closing brace) and validate.

```hcl
# main.tf — fixed
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "config" {
  content  = "app=myapp"
  filename = "${path.module}/config.txt"
}   # <-- this closing brace was missing

resource "local_file" "readme" {
  content  = "README"
  filename = "${path.module}/README.txt"
}
```

```bash
terraform validate
```

## Why this works

HCL requires every opening `{` to have a matching `}`. The `terraform validate` command checks syntax without making API calls.""")

    elif 'terraform-fmt' in name:
        lines.append("""## Approach

Run `terraform fmt` to auto-format the HCL code.

```bash
cd ~/terraform-project
terraform fmt

# Verify it's now formatted correctly
terraform fmt -check  # exits 0 if already formatted
```

The formatter fixes indentation, alignment, and spacing:
```hcl
# Before (unformatted):
terraform {
required_providers {
local = {
source = "hashicorp/local"

# After (formatted):
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
```

## Why this works

`terraform fmt` is an opinionated formatter — it enforces the canonical HCL style. `-check` mode exits non-zero if any files need formatting, useful in CI.""")

    elif 'variables' in name:
        lines.append("""## Solution

```hcl
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
  description = "Number of config files to create"
  type        = number
  default     = 3
}

resource "local_file" "config" {
  count    = var.file_count
  content  = "project=${var.project_name}\\nenv=${var.environment}\\n"
  filename = "${path.module}/config-${count.index}.txt"
}
```

## Why this works

Variables decouple configuration from code. `default` values make them optional. Reference with `var.name`. Override at runtime with `-var` flags or `terraform.tfvars`.""")

    elif 'outputs' in name:
        lines.append("""## Solution

```hcl
resource "random_pet" "server" {
  length = 2
}

resource "local_file" "config" {
  content  = "server=${random_pet.server.id}\\n"
  filename = "${path.module}/config.txt"
}

resource "random_integer" "priority" {
  min = 1
  max = 100
}

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
```

## Why this works

Outputs expose values after `apply`. They're useful for passing data between modules or displaying important information. `description` is required by best practices.""")

    elif 'state-management' in name:
        lines.append("""## Approach

Rename the resource in both the state and the configuration.

```bash
cd ~/terraform-project

# Step 1: rename in state
terraform state mv random_pet.server random_pet.app_server

# Step 2: update main.tf to match
sed -i 's/resource "random_pet" "server"/resource "random_pet" "app_server"/' main.tf
sed -i 's/random_pet\.server\./random_pet.app_server./g' main.tf

# Step 3: verify no changes pending
terraform plan  # should show "No changes"
```

## Why this works

`terraform state mv` renames a resource in the state file without destroying/recreating it. The config must be updated to match, otherwise Terraform sees a deletion and creation.""")

    elif 'import' in name:
        lines.append("""## Approach

Write a `local_file` resource that matches the existing file, then import it.

```hcl
# main.tf — add this resource
resource "local_file" "app_config" {
  content  = file("${path.module}/app-config.txt")
  filename = "${path.module}/app-config.txt"
}
```

```bash
cd ~/terraform-project

# Import the existing file into state
terraform import local_file.app_config ~/terraform-project/app-config.txt

# Verify no changes pending
terraform plan  # should show "No changes"
```

## Why this works

`terraform import` brings existing infrastructure under Terraform management without recreating it. The resource config must match the actual state — otherwise `plan` will show changes.""")

    elif 'backend-config' in name:
        lines.append("""## Solution

```hcl
# main.tf
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
  backend "local" {
    path = "state/terraform.tfstate"
  }
}

resource "local_file" "config" {
  content  = "app=myapp\\n"
  filename = "${path.module}/app.conf"
}
```

```bash
terraform init   # re-init to configure the backend
terraform apply -auto-approve
ls state/        # tfstate file should be here
```

## Why this works

The `backend` block configures where state is stored. The `local` backend stores state in a file. Changing the backend requires `terraform init` to migrate existing state.""")

    elif 'workspace' in name:
        lines.append("""## Approach

Create a `staging` workspace and use `terraform.workspace` in the config.

```bash
cd ~/terraform-project

# Create and switch to staging workspace
terraform workspace new staging
terraform workspace list  # should show staging

# Update main.tf to use workspace
```

```hcl
resource "local_file" "env_config" {
  content  = "environment=${terraform.workspace}\\n"
  filename = "${path.module}/env.conf"
}
```

```bash
terraform apply -auto-approve
cat env.conf  # should show "environment=staging"
```

## Why this works

Workspaces let you manage multiple environments with the same config. `terraform.workspace` returns the current workspace name. Each workspace has its own state file.""")

    elif 'modules' in name:
        lines.append("""## Solution

```hcl
# modules/config/main.tf
variable "app_name" {
  type = string
}

variable "environment" {
  type = string
}

resource "local_file" "config" {
  content  = "app=${var.app_name}\\nenv=${var.environment}\\n"
  filename = "${path.module}/app.conf"
}

output "config_path" {
  value = local_file.config.filename
}
```

```hcl
# main.tf (root)
module "app_config" {
  source      = "./modules/config"
  app_name    = "myapp"
  environment = "production"
}

output "config_file" {
  value = module.app_config.config_path
}
```

## Why this works

Modules encapsulate reusable infrastructure. Input variables are passed as arguments. Outputs expose values to the calling module. `source = "./modules/config"` references a local module.""")

    elif 'data-sources' in name:
        lines.append("""## Solution

```hcl
# Read existing files as data sources
data "local_file" "source_config" {
  filename = "${path.module}/source/config.txt"
}

data "local_file" "source_version" {
  filename = "${path.module}/source/version.txt"
}

# Use the data in a resource
resource "local_file" "combined" {
  content  = "config=${data.local_file.source_config.content}version=${data.local_file.source_version.content}"
  filename = "${path.module}/combined.txt"
}
```

## Why this works

Data sources read existing infrastructure without managing it. `data.local_file.name.content` accesses the file contents. Data sources are read during `plan`, before any resources are created.""")

    elif 'count' in name:
        lines.append("""## Solution

```hcl
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
terraform plan  # should show 3 resources to create
terraform apply -auto-approve
ls *.txt
```

## Why this works

`count` creates multiple instances of a resource. `count.index` is the current iteration (0, 1, 2...). Access the list with `var.environments[count.index]`.""")

    elif 'for-each' in name:
        lines.append("""## Solution

```hcl
variable "services" {
  type = map(object({
    port = number
    env  = string
  }))
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
```

## Why this works

`for_each` creates one instance per map entry. `each.key` is the map key; `each.value` is the value. Unlike `count`, `for_each` resources are identified by key, not index — safer for additions/removals.""")

    elif 'local-values' in name:
        lines.append("""## Solution

```hcl
locals {
  project     = "myapp"
  environment = "production"
  common_tags = {
    project     = local.project
    environment = local.environment
    managed_by  = "terraform"
  }
  config_content = "project=${local.project}\\nenv=${local.environment}\\n"
}

resource "local_file" "config" {
  content  = local.config_content
  filename = "${path.module}/config.txt"
}

resource "random_pet" "name" {
  prefix = local.project
}
```

## Why this works

`locals` define computed values used multiple times. They reduce repetition and make changes easier — update once, applies everywhere. Reference with `local.name`.""")

    elif 'dynamic-blocks' in name:
        lines.append("""## Solution

```hcl
variable "provisioners" {
  type    = list(string)
  default = ["web", "api", "worker"]
}

resource "null_resource" "app" {
  dynamic "provisioner" {
    for_each = var.provisioners
    content {
      # provisioner.value is the current item
    }
  }
}

# More practical example with local_file
resource "local_file" "configs" {
  for_each = toset(var.provisioners)
  content  = "provisioner=${each.value}\\n"
  filename = "${path.module}/${each.value}.conf"
}
```

## Why this works

`dynamic` blocks generate repeated nested blocks from a list or map. `for_each` iterates the collection; `content` defines the block body. `provisioner.value` (or the iterator name) accesses the current item.""")

    elif 'conditional' in name:
        lines.append("""## Solution

```hcl
variable "environment" {
  type    = string
  default = "production"
}

variable "enable_debug" {
  type    = bool
  default = false
}

resource "local_file" "config" {
  content  = "environment=${var.environment}\\ndebug=${var.enable_debug}\\n"
  filename = "${path.module}/config.txt"
}

# Conditional resource — only create debug log in non-production
resource "local_file" "debug_log" {
  count    = var.environment != "production" ? 1 : 0
  content  = "debug mode enabled\\n"
  filename = "${path.module}/debug.log"
}
```

## Why this works

The ternary operator `condition ? true_val : false_val` works in HCL. Using `count = condition ? 1 : 0` conditionally creates a resource. `var.environment != "production"` evaluates to true/false.""")

    elif 'depends-on' in name:
        lines.append("""## Solution

```hcl
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

resource "local_file" "readme" {
  content  = "README\\n"
  filename = "${path.module}/output/README.txt"

  depends_on = [local_file.app_config]
}
```

## Why this works

`depends_on` creates explicit ordering when Terraform can't infer it from references. Without it, Terraform might try to create `app_config` before the directory exists.""")

    elif 'lifecycle' in name:
        lines.append("""## Solution

```hcl
resource "local_file" "config" {
  content  = "app=myapp\\nversion=1.0\\n"
  filename = "${path.module}/config.txt"

  lifecycle {
    create_before_destroy = true   # create new before destroying old
    prevent_destroy       = false  # set true to protect critical resources
    ignore_changes        = [content]  # don't update if content changes externally
  }
}

resource "random_pet" "name" {
  lifecycle {
    create_before_destroy = true
  }
}
```

## Why this works

`lifecycle` blocks customize resource behavior. `create_before_destroy` prevents downtime during replacement. `prevent_destroy` protects critical resources. `ignore_changes` prevents drift detection for specified attributes.""")

    elif 'null-resource' in name:
        lines.append("""## Solution

```hcl
resource "null_resource" "setup" {
  triggers = {
    always_run = timestamp()  # re-run every apply
  }

  provisioner "local-exec" {
    command = "echo 'Setup complete' > ${path.module}/setup.log"
  }
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ${path.module}/setup.log"
  }
}
```

## Why this works

`null_resource` has no real infrastructure — it's a container for `provisioner` blocks. `triggers` controls when it re-runs. `when = destroy` runs the provisioner on `terraform destroy`.""")

    elif 'provisioners' in name:
        lines.append("""## Solution

```hcl
resource "null_resource" "app_setup" {
  provisioner "local-exec" {
    command = "echo 'Provisioning...' && mkdir -p ${path.module}/app"
  }

  provisioner "local-exec" {
    command = "echo 'app=myapp' > ${path.module}/app/config.txt"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf ${path.module}/app"
  }
}
```

> **Note:** Provisioners are a last resort. Prefer native Terraform resources when possible.

## Why this works

`local-exec` runs commands on the machine running Terraform. Multiple provisioners run in order. `when = destroy` runs during `terraform destroy`. Provisioners don't track state — they run once on create.""")

    elif 'random-provider' in name:
        lines.append("""## Solution

```hcl
resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
  prefix    = "srv"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

resource "random_password" "db_pass" {
  length  = 16
  special = true
}

resource "local_file" "config" {
  content  = "server=${random_pet.server_name.id}\\nport=${random_integer.port.result}\\n"
  filename = "${path.module}/config.txt"
}
```

## Why this works

The `random` provider generates values that are stable across applies (stored in state). `random_pet` generates human-readable names. `random_password` generates secure passwords.""")

    elif 'sensitive' in name:
        lines.append("""## Solution

```hcl
variable "db_password" {
  type      = string
  sensitive = true    # won't appear in plan/apply output
  default   = "changeme123"
}

variable "api_key" {
  type      = string
  sensitive = true
  default   = "abc123"
}

resource "local_file" "config" {
  content  = "db_pass=${var.db_password}\\napi_key=${var.api_key}\\n"
  filename = "${path.module}/secrets.conf"
}

output "app_id" {
  value = "myapp-prod"
}

output "password_set" {
  value     = length(var.db_password) > 0
  sensitive = true    # output is also sensitive
}
```

## Why this works

`sensitive = true` on variables and outputs redacts values in CLI output (shown as `(sensitive value)`). The values are still stored in state — use remote state with encryption for real secrets.""")

    elif 'splat' in name:
        lines.append("""## Solution

```hcl
variable "instance_count" {
  default = 3
}

resource "random_pet" "servers" {
  count = var.instance_count
}

# Splat expression — collect all IDs
output "all_server_names" {
  value = random_pet.servers[*].id  # splat: get .id from all instances
}

resource "local_file" "inventory" {
  content  = join("\\n", random_pet.servers[*].id)
  filename = "${path.module}/inventory.txt"
}
```

## Why this works

The splat expression `resource[*].attribute` collects an attribute from all instances of a `count`-based resource into a list. Equivalent to `[for r in random_pet.servers : r.id]`.""")

    elif 'string-interpolation' in name:
        lines.append("""## Solution

```hcl
variable "app_name" { default = "myapp" }
variable "environment" { default = "production" }
variable "version" { default = "1.0.0" }

locals {
  full_name = "${var.app_name}-${var.environment}"
  tag       = "v${var.version}"
}

resource "local_file" "config" {
  content  = <<-EOT
    app_name    = ${var.app_name}
    environment = ${var.environment}
    full_name   = ${local.full_name}
    tag         = ${local.tag}
  EOT
  filename = "${path.module}/config.txt"
}
```

## Why this works

`"${expression}"` interpolates values into strings. `<<-EOT ... EOT` is a heredoc (strips leading whitespace). String functions like `upper()`, `lower()`, `format()` work inside interpolations.""")

    elif 'template-file' in name:
        lines.append("""## Solution

```hcl
# config.tftpl (already created by setup)
# Application Configuration
# [general]
# name = "${app_name}"
# ...

resource "local_file" "config" {
  content = templatefile("${path.module}/config.tftpl", {
    app_name       = "myapp"
    app_port       = 8080
    app_env        = "production"
    max_connections = 100
    enable_ssl     = false
    ports          = [80, 443, 8080]
  })
  filename = "${path.module}/app.conf"
}
```

## Why this works

`templatefile(path, vars)` renders a `.tftpl` file with the given variables. It's more readable than inline heredocs for complex templates. The template uses `${var}` for interpolation and `%{ for/if }` for control flow.""")

    elif 'try-function' in name:
        lines.append("""## Solution

```hcl
variable "config" {
  type    = any
  default = {
    name    = "myapp"
    port    = 8080
    timeout = null
  }
}

locals {
  # try() returns the first successful expression
  app_name = try(var.config.name, "default-app")
  app_port = try(var.config.port, 80)
  timeout  = try(var.config.timeout, 30)  # null falls through to default
}

resource "local_file" "config" {
  content  = "name=${local.app_name}\\nport=${local.app_port}\\ntimeout=${local.timeout}\\n"
  filename = "${path.module}/config.txt"
}
```

## Why this works

`try(expr1, expr2, ...)` evaluates expressions in order and returns the first one that doesn't produce an error. Useful for optional attributes that might be null or missing.""")

    elif 'type-constraints' in name:
        lines.append("""## Solution

```hcl
variable "app_name" {
  type        = string
  description = "Application name"
  default     = "myapp"
}

variable "port" {
  type        = number
  description = "Application port"
  default     = 8080
}

variable "allowed_hosts" {
  type        = list(string)
  description = "Allowed hostnames"
  default     = ["localhost", "example.com"]
}

variable "feature_flags" {
  type = object({
    debug   = bool
    metrics = bool
    tracing = bool
  })
  default = {
    debug   = false
    metrics = true
    tracing = false
  }
}
```

## Why this works

Type constraints catch configuration errors early. `string`, `number`, `bool` are primitives. `list(type)`, `map(type)`, `set(type)` are collections. `object({})` defines a structured type with named attributes.""")

    elif 'validation-rules' in name:
        lines.append("""## Solution

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

variable "port" {
  type = number
  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "Port must be between 1024 and 65535."
  }
}

variable "app_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*$", var.app_name))
    error_message = "App name must start with a letter and contain only lowercase letters, numbers, and hyphens."
  }
}
```

## Why this works

`validation` blocks run before any resources are created. `condition` is a boolean expression. `error_message` is shown when validation fails. `can()` returns false instead of erroring if the expression fails.""")

    elif 'moved-blocks' in name:
        lines.append("""## Approach

Use `moved` blocks to rename resources without destroying them.

```hcl
# Add to main.tf
moved {
  from = local_file.old_config
  to   = local_file.new_config
}

# Rename the resource block
resource "local_file" "new_config" {  # was "old_config"
  content  = "app=myapp\\n"
  filename = "${path.module}/config.txt"
}
```

```bash
terraform plan   # should show "1 to move, 0 to add, 0 to destroy"
terraform apply -auto-approve
```

## Why this works

`moved` blocks tell Terraform that a resource was renamed. Without it, Terraform would destroy the old resource and create a new one. With it, the state entry is simply renamed.""")

    elif 'override' in name:
        lines.append("""## Solution

Create an override file to change values for a specific environment.

```hcl
# main_override.tf (or any *_override.tf file)
resource "random_pet" "name" {
  length    = 3        # override: change from 2 to 3
  separator = "_"      # override: change separator
}

resource "local_file" "config" {
  content = "environment=development\\n"  # override content
}
```

```bash
terraform plan  # override file is automatically loaded
```

## Why this works

Files ending in `_override.tf` or named `override.tf` are loaded last and merge with the main config. They're useful for local development overrides without modifying the main config.""")

    elif 'drift' in name:
        lines.append("""## Approach

Detect the drift and reconcile state with the actual file.

```bash
cd ~/terraform-project

# See what changed
terraform plan  # shows drift between state and actual file

# Option 1: restore the file to match state
terraform apply -auto-approve  # overwrites the manually changed file

# Option 2: update config to match the drift
# Edit main.tf to match the new content, then apply
```

## Why this works

Terraform detects drift by comparing the state file against the actual infrastructure. `terraform apply` reconciles them by updating infrastructure to match the desired config. For file resources, it overwrites the file.""")

    else:
        lines.append("""## Approach

```bash
cd ~/terraform-project
terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## Key concepts

- `terraform init` downloads providers
- `terraform validate` checks HCL syntax
- `terraform plan` shows what will change
- `terraform apply` makes the changes
- `terraform state list` shows managed resources""")

    return "\n".join(lines)


# ── Main dispatcher ─────────────────────────────────────────────────────────

def generate_solution(ch_dir: Path) -> str:
    name = ch_dir.name
    data = yaml.safe_load((ch_dir / "challenge.yaml").read_text())
    vs   = read(ch_dir / "validate.sh")
    files_dir = ch_dir / "files"
    cat  = data.get("category", "")

    if cat == "linux":
        return solve_linux(name, data, vs, files_dir)
    elif cat == "ansible":
        return solve_ansible(name, data, vs, files_dir)
    elif cat == "docker":
        return solve_docker(name, data, vs, files_dir)
    elif cat == "kubernetes":
        return solve_k8s(name, data, vs, files_dir)
    elif cat == "terraform":
        return solve_terraform(name, data, vs, files_dir)
    else:
        return f"# Solution: {data['name']}\n\nSolution coming soon."

def main():
    generated = 0
    skipped   = 0
    for ch_dir in sorted(CHALLENGES.iterdir()):
        if not ch_dir.is_dir():
            continue
        if not (ch_dir / "challenge.yaml").is_file():
            continue
        out = ch_dir / "solution.md"
        if out.exists():
            skipped += 1
            continue
        try:
            content = generate_solution(ch_dir)
            out.write_text(content + "\n")
            generated += 1
        except Exception as e:
            print(f"ERROR {ch_dir.name}: {e}")

    print(f"Generated: {generated}  Skipped (already exist): {skipped}")

if __name__ == "__main__":
    main()
