#!/bin/bash

# Demo script showing all 3 ConfigMap types

set -e

echo "🎬 ConfigMap Demo - All 3 Types"
echo "================================"

# Create namespace
kubectl create namespace demo --dry-run=client -o yaml | kubectl apply -f -

# Type A: env
echo ""
echo "📌 TYPE A: Environment Variables (env)"
echo "---------------------------------------"
kubectl create configmap app-config \
  --from-literal=DB_HOST=prod-db \
  --from-literal=API_URL=https://api.company.com \
  --namespace=demo \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f ../manifests/deployment-env.yaml

echo "Waiting for pods..."
sleep 10

POD_NAME=$(kubectl get pods -n demo -l app=myapp -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $POD_NAME"
kubectl exec -n demo $POD_NAME -- env | grep -E 'DB_HOST|API_URL'

# Type B: volume
echo ""
echo "📌 TYPE B: Volume Mount (files)"
echo "-------------------------------"
kubectl create configmap nginx-config \
  --from-file=../examples/nginx.conf \
  --namespace=demo \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f ../manifests/deployment-volume.yaml

echo "Waiting for pods..."
sleep 10

NGINX_POD=$(kubectl get pods -n demo -l app=nginx -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $NGINX_POD"
kubectl exec -n demo $NGINX_POD -- ls -la /etc/nginx/

# Type C: envFrom
echo ""
echo "📌 TYPE C: Bulk Injection (envFrom)"
echo "------------------------------------"
kubectl create configmap app-config-bulk \
  --from-literal=DB_HOST=prod-db \
  --from-literal=DB_PORT=5432 \
  --from-literal=API_URL=https://api.company.com \
  --from-literal=LOG_LEVEL=info \
  --namespace=demo \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f ../manifests/deployment-envfrom.yaml

echo "Waiting for pods..."
sleep 10

BULK_POD=$(kubectl get pods -n demo -l app=myapp-bulk -o jsonpath='{.items[0].metadata.name}')
echo "Pod: $BULK_POD"
kubectl exec -n demo $BULK_POD -- env | grep -E 'DB_|API_|LOG_'

echo ""
echo "✅ Demo complete! All 3 types demonstrated."
