# Lab 6: Immutable ConfigMaps (Production Safety)

## Objective
Learn to create immutable ConfigMaps for production safety.

## Why Immutable?

In production, accidental config changes can cause:
- Service outages
- Data corruption
- Security breaches

Immutable ConfigMaps prevent this.

## Steps

### 1. Create Immutable ConfigMap

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-config
  namespace: production
immutable: true
data:
  DB_HOST: "prod-db.internal"
  API_URL: "https://api.company.com"
  LOG_LEVEL: "warn"
EOF
```

### 2. Try to Modify It

```bash
kubectl edit configmap prod-config -n production
```

**Result:** Edit will be rejected!

### 3. Proper Way to Update

Create new version:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-config-v2
  namespace: production
immutable: true
data:
  DB_HOST: "prod-db-v2.internal"
  API_URL: "https://api.company.com"
  LOG_LEVEL: "warn"
EOF
```

Update deployment:

```bash
kubectl patch deployment myapp -n production \
  -p '{"spec":{"template":{"spec":{"containers":[{"name":"app","envFrom":[{"configMapRef":{"name":"prod-config-v2"}}]}]}}}}'
```

## Benefits

1. ✅ Prevents accidental changes
2. ✅ Forces versioning
3. ✅ Audit trail
4. ✅ Rollback capability

## Best Practice

Use immutable ConfigMaps in production, mutable in dev/staging.
