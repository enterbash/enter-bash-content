# Solution: Manage LVM Volumes

## What the validator checks

- **Check LV is mounted**: /mnt/appdata is not mounted
- Logical volume has not been extended (size: <value>KB)
- Volume group still has significant free space (<value>MB)
- **Check data is preserved**: Original data.txt is missing

## Solution

```bash
sudo lvextend -l +100%FREE /dev/vg_data/lv_app
sudo resize2fs /dev/vg_data/lv_app
df -h /mnt/appdata
```
