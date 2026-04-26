#!/bin/bash

# Check LV is mounted
if ! mountpoint -q /mnt/appdata 2>/dev/null; then
  echo "FAIL: /mnt/appdata is not mounted"
  exit 1
fi

# Check LV size is larger than initial 64MB (should be ~256MB)
LV_SIZE_KB=$(df -k /mnt/appdata | tail -1 | awk '{print $2}')
if [ "$LV_SIZE_KB" -lt 120000 ]; then
  echo "FAIL: Logical volume has not been extended (size: ${LV_SIZE_KB}KB)"
  exit 1
fi

# Check VG has minimal free space (most should be allocated)
VG_FREE=$(sudo vgs --noheadings -o vg_free --units m vg_data 2>/dev/null | tr -d ' m.' | cut -d, -f1)
if [ "${VG_FREE:-999}" -gt 20 ]; then
  echo "FAIL: Volume group still has significant free space (${VG_FREE}MB)"
  exit 1
fi

# Check data is preserved
if [ ! -f /mnt/appdata/data.txt ]; then
  echo "FAIL: Original data.txt is missing"
  exit 1
fi

echo "PASS: LVM volume extended and filesystem resized"
exit 0
