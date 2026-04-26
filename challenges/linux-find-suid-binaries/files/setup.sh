#!/bin/bash
set -e

# Create suspicious SUID binaries in unusual locations
cp /bin/bash /tmp/backdoor
chmod u+s /tmp/backdoor

cp /bin/sh /home/runner/.hidden-shell
chmod u+s /home/runner/.hidden-shell

mkdir -p /var/tmp/tools
cp /bin/cat /var/tmp/tools/rootcat
chmod u+s /var/tmp/tools/rootcat
