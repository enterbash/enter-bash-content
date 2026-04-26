#!/bin/bash
# Setup: clean up
sudo docker rm -f envbox envbox2 2>/dev/null || true
rm -f ~/app.env
