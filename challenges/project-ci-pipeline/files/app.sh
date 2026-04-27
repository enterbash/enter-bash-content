#!/bin/bash
# Simple shell application with functions

greet() {
  local name="${1:-World}"
  echo "Hello, ${name}!"
}

add() {
  local a="${1:-0}"
  local b="${2:-0}"
  echo $((a + b))
}

version() {
  echo "1.0.0"
}

# Main
if [ "${1}" = "run" ]; then
  greet "Enter Bash"
  echo "2 + 3 = $(add 2 3)"
  echo "Version: $(version)"
fi
