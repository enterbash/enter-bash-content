#!/bin/bash
# Setup: create storage dir with wrong permissions and a broken container
mkdir -p ~/storage
sudo chown root:root ~/storage
sudo chmod 755 ~/storage
sudo docker rm -f storebox storebox-fixed 2>/dev/null || true
sudo docker run -d --name storebox -v ~/storage:/data -u 1000 alpine sleep infinity 2>/dev/null || true
