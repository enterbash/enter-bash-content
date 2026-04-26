#!/bin/bash
# Setup: create three containers, one with errors
sudo docker rm -f app1 app2 app3 2>/dev/null || true
rm -f ~/error-report.txt

sudo docker run -d --name app1 alpine sh -c 'while true; do echo "INFO: app1 running normally"; sleep 5; done'
sudo docker run -d --name app2 alpine sh -c 'while true; do echo "ERROR: database connection refused on port 5432"; sleep 3; done'
sudo docker run -d --name app3 alpine sh -c 'while true; do echo "INFO: app3 processing requests"; sleep 5; done'

sleep 3
