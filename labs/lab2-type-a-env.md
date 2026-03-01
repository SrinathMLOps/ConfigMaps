# Lab 2: ConfigMap Type A - Environment Variables

## Objective
Learn to inject specific ConfigMap keys as environment variables.

## Scenario
Deploy a Node.js app that needs database host and API URL.

## Steps

### 1. Create ConfigMap

```bash
kubectl create configmap app-config \
  --from-literal=DB_HOST=prod-db.example.com \
  --from-literal=API_URL=https://api.company.com \
  --from-literal=APP_MODE=production \
  --from-literal=LOG_LEVEL=info
```

### 2. Verify ConfigMap

```bash
kubectl get configmap app-config -o yaml
```

### 3. Create Deployment with Type A

```bash
kubectl apply -f ../manifests/deployment-env.yaml
```

### 4. Verify Environment Variables

```bash
POD_NAME=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env | grep -E 'DB_HOST|API_URL'
```

## Expected Output

```
DB_HOST=prod-db.example.com
API_URL=https://api.company.com
```

## Key Concepts

- **Selective injection**: Only specified keys are injected
- **Manual mapping**: Each env var must be explicitly defined
- **No auto-update**: Pod restart required for changes

## Exercise

1. Update DB_HOST to a new value
2. Observe that running pods don't see the change
3. Restart deployment to apply changes

```bash
kubectl edit configmap app-config
kubectl rollout restart deployment myapp
```

## Next Steps
Proceed to [Lab 3: Type B - Volume Mounts](./lab3-type-b-volume.md)
