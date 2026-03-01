# Lab 5: Real-World Multi-Environment Setup

## Objective
Deploy the same application to Dev, Staging, and Production with different configurations.

## Scenario
You have one Docker image: `myapp:v1.0.0`

You need to deploy it to 3 environments with different configs.

## Architecture

```
Same Docker Image (myapp:v1.0.0)
         ↓
    ┌────┴────┬────────┬──────────┐
    ↓         ↓        ↓          ↓
  Dev    Staging    Prod      Prod-EU
```

## Steps

### 1. Create Namespaces

```bash
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production
```

### 2. Create Environment-Specific ConfigMaps

#### Development
```bash
kubectl create configmap app-config \
  --from-literal=DB_HOST=dev-db.internal \
  --from-literal=API_URL=https://dev-api.company.com \
  --from-literal=APP_MODE=development \
  --from-literal=LOG_LEVEL=debug \
  --from-literal=FEATURE_NEW_UI=true \
  --namespace=dev
```

#### Staging
```bash
kubectl create configmap app-config \
  --from-literal=DB_HOST=staging-db.internal \
  --from-literal=API_URL=https://staging-api.company.com \
  --from-literal=APP_MODE=staging \
  --from-literal=LOG_LEVEL=info \
  --from-literal=FEATURE_NEW_UI=true \
  --namespace=staging
```

#### Production
```bash
kubectl create configmap app-config \
  --from-literal=DB_HOST=prod-db.internal \
  --from-literal=API_URL=https://api.company.com \
  --from-literal=APP_MODE=production \
  --from-literal=LOG_LEVEL=warn \
  --from-literal=FEATURE_NEW_UI=false \
  --namespace=production
```

### 3. Deploy Same Image to All Environments

```bash
# Dev
kubectl apply -f ../manifests/deployment-envfrom.yaml -n dev

# Staging
kubectl apply -f ../manifests/deployment-envfrom.yaml -n staging

# Production
kubectl apply -f ../manifests/deployment-envfrom.yaml -n production
```

### 4. Verify Different Configurations

```bash
# Dev
kubectl exec -n dev $(kubectl get pod -n dev -l app=myapp-bulk -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'DB_HOST|LOG_LEVEL'

# Staging
kubectl exec -n staging $(kubectl get pod -n staging -l app=myapp-bulk -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'DB_HOST|LOG_LEVEL'

# Production
kubectl exec -n production $(kubectl get pod -n production -l app=myapp-bulk -o jsonpath='{.items[0].metadata.name}') -- env | grep -E 'DB_HOST|LOG_LEVEL'
```

## Expected Output

| Environment | DB_HOST | LOG_LEVEL | FEATURE_NEW_UI |
|-------------|---------|-----------|----------------|
| Dev | dev-db.internal | debug | true |
| Staging | staging-db.internal | info | true |
| Production | prod-db.internal | warn | false |

## Real-World Scenario: Emergency DB Migration

Production database needs to move:
- Old: `prod-db.internal`
- New: `prod-db-v2.internal`

### Traditional Way (Without ConfigMap)
1. Edit Dockerfile
2. Rebuild image
3. Push to registry
4. Update deployment
5. Wait for CI/CD pipeline
⏱️ **Time: 30-60 minutes**

### ConfigMap Way
```bash
kubectl edit configmap app-config -n production
# Change DB_HOST to prod-db-v2.internal
kubectl rollout restart deployment myapp-bulk -n production
```
⏱️ **Time: 30 seconds**

## Feature Flag Toggle

Marketing wants to disable new UI in production immediately:

```bash
kubectl patch configmap app-config -n production \
  -p '{"data":{"FEATURE_NEW_UI":"false"}}'

kubectl rollout restart deployment myapp-bulk -n production
```

## Best Practices Demonstrated

1. ✅ Same image across environments
2. ✅ Configuration separated from code
3. ✅ Easy to update without rebuild
4. ✅ Clear environment isolation
5. ✅ Fast incident response

## Exercise

1. Create a new environment: `qa`
2. Deploy the same app with QA-specific config
3. Toggle a feature flag
4. Simulate a DB migration

## Cleanup

```bash
kubectl delete namespace dev staging production
```

## Summary

You've learned how to:
- Use the same Docker image across environments
- Manage environment-specific configurations
- Perform rapid configuration updates
- Implement feature flags
- Handle emergency changes without rebuilding

This is production-grade Kubernetes configuration management! 🚀
