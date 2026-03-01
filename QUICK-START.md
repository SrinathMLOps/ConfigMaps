# Quick Start Guide

Get started with ConfigMaps in 5 minutes!

## Prerequisites

```bash
# Verify installations
kubectl version --client
aws --version
eksctl version
```

## Step 1: Create EKS Cluster (Optional)

If you already have a cluster, skip this step.

```bash
chmod +x scripts/setup-eks.sh
./scripts/setup-eks.sh
```

## Step 2: Create Your First ConfigMap

```bash
kubectl create configmap my-first-config \
  --from-literal=DB_HOST=prod-db \
  --from-literal=API_URL=https://api.example.com
```

## Step 3: View ConfigMap

```bash
kubectl get configmap my-first-config -o yaml
```

## Step 4: Use ConfigMap in Pod

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test
    image: busybox
    command: ['sh', '-c', 'echo "DB_HOST=\$DB_HOST" && sleep 3600']
    envFrom:
    - configMapRef:
        name: my-first-config
EOF
```

## Step 5: Verify

```bash
kubectl logs test-pod
```

Expected output:
```
DB_HOST=prod-db
```

## Next Steps

1. Complete [Lab 1: EKS Setup](./labs/lab1-eks-setup.md)
2. Learn [Type A: Environment Variables](./labs/lab2-type-a-env.md)
3. Explore [Type B: Volume Mounts](./labs/lab3-type-b-volume.md)
4. Master [Type C: Bulk Injection](./labs/lab4-type-c-envfrom.md)
5. Practice [Multi-Environment Setup](./labs/lab5-multi-env.md)

## Common Commands

```bash
# Create from literal
kubectl create configmap NAME --from-literal=KEY=VALUE

# Create from file
kubectl create configmap NAME --from-file=path/to/file

# View ConfigMap
kubectl get cm NAME -o yaml

# Edit ConfigMap
kubectl edit configmap NAME

# Delete ConfigMap
kubectl delete configmap NAME

# Restart deployment after config change
kubectl rollout restart deployment NAME
```

## Troubleshooting

### ConfigMap not found
```bash
kubectl get cm -A  # Check all namespaces
```

### Pod not picking up changes
```bash
kubectl rollout restart deployment YOUR_DEPLOYMENT
```

### Permission denied
```bash
kubectl auth can-i create configmaps
```

## Clean Up

```bash
kubectl delete pod test-pod
kubectl delete configmap my-first-config
```

For full cluster cleanup:
```bash
./scripts/cleanup-eks.sh
```
