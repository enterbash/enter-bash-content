# Solution: Manage LVM Volumes

## Approach

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

`lvextend -l +100%FREE` uses all remaining free space in the volume group. `resize2fs` then expands the ext4 filesystem to fill the new space.
