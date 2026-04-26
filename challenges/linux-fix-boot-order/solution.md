# Solution: Fix Boot Configuration

## Approach

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

`GRUB_TIMEOUT=5` sets a 5-second boot menu timeout. `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"` suppresses verbose boot messages. In a real system you'd run `sudo update-grub` to apply changes.
