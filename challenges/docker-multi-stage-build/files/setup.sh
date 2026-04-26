#!/bin/bash
# Setup: create a Go app with a single-stage Dockerfile
mkdir -p ~/goapp

cat > ~/goapp/main.go << 'GOEOF'
package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Hello from Go!\n")
	})
	fmt.Println("Server starting on :8080")
	http.ListenAndServe(":8080", nil)
}
GOEOF

cat > ~/goapp/go.mod << 'EOF'
module goapp

go 1.21
EOF

cat > ~/goapp/Dockerfile << 'EOF'
FROM golang:1.21-alpine
WORKDIR /app
COPY go.mod main.go ./
RUN go build -o main .
EXPOSE 8080
CMD ["./main"]
EOF
