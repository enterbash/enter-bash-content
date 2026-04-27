#!/bin/bash

# Check manifest exists
if [ ! -f ~/microservice/app.yaml ]; then
  echo "FAIL: ~/microservice/app.yaml not found"
  exit 1
fi

# Apply the manifest
APPLY_OUT=$(kubectl apply -f ~/microservice/app.yaml 2>&1)
if [ $? -ne 0 ]; then
  echo "FAIL: kubectl apply failed:"
  echo "$APPLY_OUT" | tail -5
  exit 1
fi

# Check ConfigMap values are strings
CM_PORT=$(kubectl get configmap web-api-config -o jsonpath='{.data.APP_PORT}' 2>/dev/null)
if [ -z "$CM_PORT" ]; then
  echo "FAIL: ConfigMap web-api-config missing or APP_PORT not set — values must be strings"
  exit 1
fi

# Check Deployment exists with 3 replicas
REPLICAS=$(kubectl get deployment web-api -o jsonpath='{.spec.replicas}' 2>/dev/null)
if [ "$REPLICAS" != "3" ]; then
  echo "FAIL: Deployment should have 3 replicas, got ${REPLICAS:-none}"
  exit 1
fi

# Check labels match (selector = template = service)
SELECTOR=$(kubectl get deployment web-api -o jsonpath='{.spec.selector.matchLabels.app}' 2>/dev/null)
TEMPLATE=$(kubectl get deployment web-api -o jsonpath='{.spec.template.metadata.labels.app}' 2>/dev/null)
SVC_SEL=$(kubectl get svc web-api-svc -o jsonpath='{.spec.selector.app}' 2>/dev/null)

if [ "$SELECTOR" != "web-api" ]; then
  echo "FAIL: Deployment selector.matchLabels.app should be 'web-api', got '$SELECTOR'"
  exit 1
fi
if [ "$TEMPLATE" != "web-api" ]; then
  echo "FAIL: Pod template labels.app should be 'web-api', got '$TEMPLATE'"
  exit 1
fi
if [ "$SVC_SEL" != "web-api" ]; then
  echo "FAIL: Service selector.app should be 'web-api', got '$SVC_SEL'"
  exit 1
fi

# Check image is nginx:alpine
IMAGE=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)
if [ "$IMAGE" != "nginx:alpine" ]; then
  echo "FAIL: Container image should be nginx:alpine, got '$IMAGE'"
  exit 1
fi

# Check container port is 80
CPORT=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}' 2>/dev/null)
if [ "$CPORT" != "80" ]; then
  echo "FAIL: containerPort should be 80, got '$CPORT'"
  exit 1
fi

# Check Service targetPort is 80
TPORT=$(kubectl get svc web-api-svc -o jsonpath='{.spec.ports[0].targetPort}' 2>/dev/null)
if [ "$TPORT" != "80" ]; then
  echo "FAIL: Service targetPort should be 80, got '$TPORT'"
  exit 1
fi

# Check resource requests exist
REQ_CPU=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null)
REQ_MEM=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].resources.requests.memory}' 2>/dev/null)
if [ -z "$REQ_CPU" ] || [ -z "$REQ_MEM" ]; then
  echo "FAIL: Container missing resource requests (need cpu: 100m, memory: 128Mi)"
  exit 1
fi

# Check resource limits exist
LIM_CPU=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].resources.limits.cpu}' 2>/dev/null)
LIM_MEM=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].resources.limits.memory}' 2>/dev/null)
if [ -z "$LIM_CPU" ] || [ -z "$LIM_MEM" ]; then
  echo "FAIL: Container missing resource limits (need cpu: 500m, memory: 256Mi)"
  exit 1
fi

# Check liveness probe exists
LIVENESS=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].livenessProbe.httpGet.path}' 2>/dev/null)
if [ -z "$LIVENESS" ]; then
  echo "FAIL: Container missing livenessProbe — add httpGet on path / port 80"
  exit 1
fi

# Check readiness probe exists
READINESS=$(kubectl get deployment web-api -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.path}' 2>/dev/null)
if [ -z "$READINESS" ]; then
  echo "FAIL: Container missing readinessProbe — add httpGet on path / port 80"
  exit 1
fi

# Wait for pods to be ready (up to 60s)
kubectl rollout status deployment/web-api --timeout=60s > /dev/null 2>&1
READY=$(kubectl get deployment web-api -o jsonpath='{.status.readyReplicas}' 2>/dev/null)
if [ "${READY:-0}" -lt 3 ]; then
  echo "FAIL: Only ${READY:-0}/3 pods are ready"
  exit 1
fi

echo "PASS: Kubernetes microservice deployed with 3 healthy replicas"
exit 0
