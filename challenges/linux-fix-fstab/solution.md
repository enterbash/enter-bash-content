# Solution: Fix Broken fstab

## Approach

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

The broken entry referenced a non-existent device `/dev/sdz99`. The correct entry uses the loop device option to mount an image file.
