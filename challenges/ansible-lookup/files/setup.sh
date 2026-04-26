#!/bin/bash
mkdir -p ~/ansible-project
mkdir -p /tmp/lookup-test
echo "Hello from lookup" > /tmp/lookup-test/greeting.txt
echo -e "line1\nline2\nline3" > /tmp/lookup-test/lines.txt
