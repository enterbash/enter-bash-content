#!/usr/bin/env python3
"""Fix remaining sudo/permission issues in setup.sh files."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent.parent / "challenges"
fixes = {
    # cat > /usr/local/bin/... → sudo tee
    "ansible-service-module/files/setup.sh": [
        ("cat > /usr/local/bin/myservice << 'SCRIPT'",
         "sudo tee /usr/local/bin/myservice << 'SCRIPT' > /dev/null"),
        ("chmod +x /usr/local/bin/myservice",
         "sudo chmod +x /usr/local/bin/myservice"),
    ],
    # mkdir /srv + writes → sudo
    "linux-fix-selinux-context/files/setup.sh": [
        ("mkdir -p /srv/www/html",
         "sudo mkdir -p /srv/www/html"),
        ("echo '<!DOCTYPE html><html><body>Welcome</body></html>' > /srv/www/html/index.html",
         "echo '<!DOCTYPE html><html><body>Welcome</body></html>' | sudo tee /srv/www/html/index.html > /dev/null"),
        ("echo 'body { color: black; }' > /srv/www/html/style.css",
         "echo 'body { color: black; }' | sudo tee /srv/www/html/style.css > /dev/null"),
        ("echo 'console.log(\"loaded\");' > /srv/www/html/app.js",
         "echo 'console.log(\"loaded\");' | sudo tee /srv/www/html/app.js > /dev/null"),
    ],
    # mkdir /opt/myapp + writes → sudo
    "linux-manage-systemd-service/files/setup.sh": [
        ("mkdir -p /opt/myapp",
         "sudo mkdir -p /opt/myapp"),
        ("cat > /opt/myapp/server.py <<'PYTHON'",
         "sudo tee /opt/myapp/server.py <<'PYTHON' > /dev/null"),
        ("chmod +x /opt/myapp/server.py",
         "sudo chmod +x /opt/myapp/server.py"),
        ("chown -R runner:runner /opt/myapp",
         "sudo chown -R runner:runner /opt/myapp"),
        ("rm -f /etc/systemd/system/myapp.service",
         "sudo rm -f /etc/systemd/system/myapp.service"),
    ],
    # mkdir /srv/nfs + writes → sudo
    "linux-setup-nfs-share/files/setup.sh": [
        ("mkdir -p /srv/nfs/shared",
         "sudo mkdir -p /srv/nfs/shared"),
        ("echo \"NFS test file\" > /srv/nfs/shared/testfile.txt",
         "echo \"NFS test file\" | sudo tee /srv/nfs/shared/testfile.txt > /dev/null"),
        ("echo \"shared data\" > /srv/nfs/shared/data.txt",
         "echo \"shared data\" | sudo tee /srv/nfs/shared/data.txt > /dev/null"),
        ("mkdir -p /mnt/nfs-test",
         "sudo mkdir -p /mnt/nfs-test"),
    ],
    # dd/mkfs/mount to /opt → sudo
    "linux-fix-disk-permissions/files/setup.sh": [
        ("dd if=/dev/zero of=/opt/data-disk.img bs=1M count=64 2>/dev/null",
         "sudo dd if=/dev/zero of=/opt/data-disk.img bs=1M count=64 2>/dev/null"),
        ("mkfs.ext4 -F /opt/data-disk.img > /dev/null 2>&1",
         "sudo mkfs.ext4 -F /opt/data-disk.img > /dev/null 2>&1"),
        ("mkdir -p /mnt/data",
         "sudo mkdir -p /mnt/data"),
        ("mount -o loop /opt/data-disk.img /mnt/data",
         "sudo mount -o loop /opt/data-disk.img /mnt/data"),
        ("chown root:root /mnt/data",
         "sudo chown root:root /mnt/data"),
        ("chmod 700 /mnt/data",
         "sudo chmod 700 /mnt/data"),
    ],
    # dd/mkfs to /opt → sudo
    "linux-fix-fstab/files/setup.sh": [
        ("dd if=/dev/zero of=/opt/disk.img bs=1M count=64 2>/dev/null",
         "sudo dd if=/dev/zero of=/opt/disk.img bs=1M count=64 2>/dev/null"),
        ("mkfs.ext4 -F /opt/disk.img > /dev/null 2>&1",
         "sudo mkfs.ext4 -F /opt/disk.img > /dev/null 2>&1"),
    ],
    # dd/lvm/mkfs/mount → sudo
    "linux-manage-lvm/files/setup.sh": [
        ("dd if=/dev/zero of=/opt/lvm-disk1.img bs=1M count=128 2>/dev/null",
         "sudo dd if=/dev/zero of=/opt/lvm-disk1.img bs=1M count=128 2>/dev/null"),
        ("dd if=/dev/zero of=/opt/lvm-disk2.img bs=1M count=128 2>/dev/null",
         "sudo dd if=/dev/zero of=/opt/lvm-disk2.img bs=1M count=128 2>/dev/null"),
        ("LOOP1=$(losetup --find --show /opt/lvm-disk1.img)",
         "LOOP1=$(sudo losetup --find --show /opt/lvm-disk1.img)"),
        ("LOOP2=$(losetup --find --show /opt/lvm-disk2.img)",
         "LOOP2=$(sudo losetup --find --show /opt/lvm-disk2.img)"),
        ("pvcreate \"$LOOP1\" \"$LOOP2\"",
         "sudo pvcreate \"$LOOP1\" \"$LOOP2\""),
        ("vgcreate vg_data \"$LOOP1\" \"$LOOP2\"",
         "sudo vgcreate vg_data \"$LOOP1\" \"$LOOP2\""),
        ("lvcreate -L 64M -n lv_app vg_data",
         "sudo lvcreate -L 64M -n lv_app vg_data"),
        ("mkfs.ext4 -F /dev/vg_data/lv_app > /dev/null 2>&1",
         "sudo mkfs.ext4 -F /dev/vg_data/lv_app > /dev/null 2>&1"),
        ("mkdir -p /mnt/appdata",
         "sudo mkdir -p /mnt/appdata"),
        ("mount /dev/vg_data/lv_app /mnt/appdata",
         "sudo mount /dev/vg_data/lv_app /mnt/appdata"),
        ("echo \"application data\" > /mnt/appdata/data.txt",
         "echo \"application data\" | sudo tee /mnt/appdata/data.txt > /dev/null"),
    ],
    # useradd → sudo
    "linux-configure-sudo/files/setup.sh": [
        ("useradd -m developer 2>/dev/null || true",
         "sudo useradd -m developer 2>/dev/null || true"),
        ("rm -f /etc/sudoers.d/developer",
         "sudo rm -f /etc/sudoers.d/developer"),
    ],
    # iptables → sudo
    "linux-fix-iptables/files/setup.sh": [
        ("iptables -F",
         "sudo iptables -F"),
        ("iptables -P INPUT DROP",
         "sudo iptables -P INPUT DROP"),
        ("iptables -P FORWARD DROP",
         "sudo iptables -P FORWARD DROP"),
        ("iptables -P OUTPUT ACCEPT",
         "sudo iptables -P OUTPUT ACCEPT"),
    ],
    # modprobe/ip → sudo
    "linux-fix-network-interface/files/setup.sh": [
        ("modprobe dummy 2>/dev/null || true",
         "sudo modprobe dummy 2>/dev/null || true"),
        ("ip link add dummy0 type dummy 2>/dev/null || true",
         "sudo ip link add dummy0 type dummy 2>/dev/null || true"),
        ("ip addr flush dev dummy0",
         "sudo ip addr flush dev dummy0"),
        ("ip addr add 192.168.99.99/24 dev dummy0",
         "sudo ip addr add 192.168.99.99/24 dev dummy0"),
        ("ip link set dummy0 down",
         "sudo ip link set dummy0 down"),
    ],
}

changed = []
for rel_path, replacements in fixes.items():
    p = root / rel_path
    if not p.is_file():
        print(f"SKIP (not found): {rel_path}")
        continue
    text = p.read_text()
    original = text
    for old, new in replacements:
        if old in text:
            text = text.replace(old, new, 1)
        else:
            print(f"  WARN: pattern not found in {rel_path}: {old[:60]}")
    if text != original:
        p.write_text(text)
        changed.append(rel_path)
        print(f"FIXED: {rel_path}")
    else:
        print(f"UNCHANGED: {rel_path}")

print(f"\nTotal fixed: {len(changed)}")
