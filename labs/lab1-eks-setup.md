# Lab 1: AWS EKS Cluster Setup

## Objective
Set up an AWS EKS cluster for ConfigMap demonstrations.

## Prerequisites
- AWS CLI installed and configured
- kubectl installed
- eksctl installed

## Steps

### 1. Create EKS Cluster

```bash
eksctl create cluster \
  --name configmap-demo \
  --region us-east-1 \
  --nodegroup-name standard-workers \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed
```

### 2. Verify Cluster

```bash
kubectl get nodes
kubectl cluster-info
```

### 3. Create Namespace

```bash
kubectl create namespace demo
kubectl config set-context --current --namespace=demo
```

## Expected Output

```
NAME                                          STATUS   ROLES    AGE   VERSION
ip-192-168-1-100.us-east-1.compute.internal   Ready    <none>   2m    v1.28.0
ip-192-168-2-200.us-east-1.compute.internal   Ready    <none>   2m    v1.28.0
```

## Next Steps
Proceed to [Lab 2: Type A - Environment Variables](./lab2-type-a-env.md)
