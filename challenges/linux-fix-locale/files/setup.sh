#!/bin/bash
set -e

# Break locale settings
export LANG=zz_ZZ.UTF-8
export LC_ALL=zz_ZZ.UTF-8

# Write broken locale to system config
sudo tee /etc/default/locale <<'EOF' > /dev/null
LANG=zz_ZZ.UTF-8
LC_ALL=zz_ZZ.UTF-8
EOF

# Remove en_US locale if generated
sed -i 's/^en_US.UTF-8/# en_US.UTF-8/' /etc/locale.gen 2>/dev/null || true
