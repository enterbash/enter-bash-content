#!/bin/bash
mkdir -p ~/ansible-project

# Create a fake service script
cat > /usr/local/bin/myservice << 'SCRIPT'
#!/bin/bash
case "$1" in
  start)
    echo $$ > /tmp/myservice.pid
    echo "myservice started" > /tmp/myservice.status
    ;;
  stop)
    rm -f /tmp/myservice.pid
    echo "myservice stopped" > /tmp/myservice.status
    ;;
  status)
    if [ -f /tmp/myservice.pid ]; then
      echo "running"
    else
      echo "stopped"
    fi
    ;;
  *)
    echo "Usage: myservice {start|stop|status}"
    exit 1
    ;;
esac
SCRIPT
chmod +x /usr/local/bin/myservice
