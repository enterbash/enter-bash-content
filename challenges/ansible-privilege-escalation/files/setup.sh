#!/bin/bash
mkdir -p ~/ansible-project
# Create a deploy user for the challenge
id deploy > /dev/null 2>&1 || useradd -m -s /bin/bash deploy
