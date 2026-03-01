# Lab 4: ConfigMap Type C - Bulk Injection (envFrom)

## Objective
Learn to inject ALL ConfigMap keys as environment variables automatically.

## Scenario
Deploy a 12-factor app with many configuration values.

## Steps

### 1. Create ConfigMap with Multiple Keys

```bash
kubectl create configmap app-config-bulk \
  --from-literal=DB_HOST=prod-db \
  --from-literal=DB_PORT=5432 \
  --from-literal=DB_NAME=myapp \
  --from-literal=API_URL=https://api.company.com \
  --from-literal=API_TIMEOUT=30 \
  --from-literal=FEATURE_NEW_UI=true \
  --from-literal=FEATURE_PAYMENTS=false \
  --from-literal=APP_MODE=production \
  --from-literal=LOG_LEVEL=info \
  --from-literal=CACHE_ENABLED=true
```

### 2. Deploy with envFrom

```bash
kubectl apply -f ../manifests/deployment-envfrom.yaml
```

### 3. Verify All Variables Injected

```bash
POD_NAME=$(kubectl get pods -l app=myapp-bulk -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env | sort
```

## Expected Output

All 10 keys should appear as environment variables:

```
API_TIMEOUT=30
API_URL=https://api.company.com
APP_MODE=production
CACHE_ENABLED=true
DB_HOST=prod-db
DB_NAME=myapp
DB_PORT=5432
FEATURE_NEW_UI=true
FEATURE_PAYMENTS=false
LOG_LEVEL=info
```

## Key Concepts

- **Automatic injection**: No need to specify each key
- **All or nothing**: All keys become env vars
- **Best for**: 12-factor apps with many configs
- **Naming**: Key names become env var names directly

## Comparison: Type A vs Type C

### Type A (env)
```yaml
env:
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: DB_HOST
  - name: DB_PORT
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: DB_PORT
  # ... repeat for each key
```

### Type C (envFrom)
```yaml
envFrom:
  - configMapRef:
      name: app-config-bulk
```

Much cleaner! 🎉

## Exercise

1. Add a new key to ConfigMap
2. Restart deployment
3. Verify new key appears automatically

```bash
kubectl patch configmap app-config-bulk -p '{"data":{"NEW_FEATURE":"enabled"}}'
kubectl rollout restart deployment myapp-bulk
kubectl exec $POD_NAME -- env | grep NEW_FEATURE
```

## Next Steps
Proceed to [Lab 5: Multi-Environment Setup](./lab5-multi-env.md)
