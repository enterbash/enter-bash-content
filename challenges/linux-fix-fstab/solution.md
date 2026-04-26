# Solution: Fix Broken fstab

## What the validator checks

- **Check that /mnt/data is mounted**: /mnt/data is not mounted
- **Check that fstab has a valid entry for /mnt/data**: /etc/fstab does not have correct entry for /mnt/data
- **Check that the broken entry is removed**: Broken /dev/sdz99 entry still in fstab
- **Check mount -a works without errors**: mount -a fails

## Solution

```bash
# Remove the broken entry (references non-existent /dev/sdz99)
sudo sed -i '/sdz99/d' /etc/fstab

# Add correct loop-mount entry
echo '/opt/disk.img  /mnt/data  ext4  loop  0  0' | sudo tee -a /etc/fstab

sudo mount -a
mountpoint /mnt/data
```
