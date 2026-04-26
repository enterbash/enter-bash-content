# Solution: Set Up NFS Share

## Approach

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

`/etc/exports` defines what directories are shared and to whom. `exportfs -ra` re-reads the file. The `rw` option allows read-write access.
