#!/bin/bash
# Setup: create container with a log file
sudo docker rm -f filebox 2>/dev/null || true
sudo docker run -d --name filebox alpine sh -c 'echo "2024-01-01 ERROR: connection timeout" > /var/log/app.log && echo "2024-01-01 INFO: server started" >> /var/log/app.log && sleep infinity'
rm -f ~/extracted.log ~/inject.conf
