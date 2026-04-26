# Solution: Fix Boot Configuration

## What the validator checks

- **Check GRUB_TIMEOUT is 5**: GRUB_TIMEOUT should be 5
- **Check GRUB_CMDLINE_LINUX_DEFAULT has quiet splash**: GRUB_CMDLINE_LINUX_DEFAULT should be \
- **Check GRUB_CMDLINE_LINUX is empty**: GRUB_CMDLINE_LINUX should be empty

## Solution

```bash
sudo tee /etc/default/grub << 'EOF'
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR=`lsb_release -i -s 2>/dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOF
cat /etc/default/grub
```
