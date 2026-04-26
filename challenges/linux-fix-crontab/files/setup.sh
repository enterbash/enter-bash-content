#!/bin/bash
set -e

# Create data to back up
mkdir -p /home/runner/data
echo "important data" > /home/runner/data/file1.txt
echo "more data" > /home/runner/data/file2.txt
mkdir -p /home/runner/backups

# Create a backup script with a bug (wrong source path)
cat > /home/runner/backup.sh <<'SCRIPT'
#!/bin/bash
tar czf /home/runner/backups/backup.tar.gz -C /home/runner data
SCRIPT

# Remove execute permission
chmod 644 /home/runner/backup.sh

# Set up a broken crontab (wrong syntax: hour and minute swapped, extra field)
echo "2 0 * * * * /home/runner/backup.sh" | crontab -

# Start cron service
sudo service cron start 2>/dev/null || true
