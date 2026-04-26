# Solution: Set Up NFS Share

## What the validator checks

- **Check exports file has an entry**: /etc/exports does not export /srv/nfs/shared
- **Check the export has rw option**: NFS export is not configured for read-write
- **Check mount point exists and is mounted**: /mnt/nfs-test is not mounted
- **Check we can read files from the mount**: Cannot read testfile.txt from NFS mount

## Solution

```bash
echo "/srv/nfs/shared *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra
sudo service nfs-kernel-server start
sudo mount -t nfs localhost:/srv/nfs/shared /mnt/nfs-test
ls /mnt/nfs-test/
```
