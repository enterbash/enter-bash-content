#!/bin/bash
# Setup: clean up
sudo docker rm -f always-up on-fail unless-manual 2>/dev/null || true
