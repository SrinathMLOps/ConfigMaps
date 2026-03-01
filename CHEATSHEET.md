# ConfigMap Cheat Sheet

## Create ConfigMap

### From Literal Values
```bash
kubectl create configmap app-config \
  --from-literal=DB_HOST=prod-db \
  --from-literal=API_URL=https://api.example.com
```

### From File
```bash
kubectl create configmap nginx-config \
  --from-file=nginx.conf
```

### From Directory
```bash
kubectl create configmap app-configs \
  --from-file=config-dir/
```

### From YAML
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DB_HOST: "prod-db"
  API_URL: "https://api.example.com"
```

## View ConfigMap

```bash
# List all
kubectl get configmaps
kubectl get cm

# Describe
kubectl describe cm app-config

# View YAML
kubectl get cm app-config -o yaml

# View JSON
kubectl get cm app-config -o json
```

## Update ConfigMap

```bash
# Edit interactively
kubectl edit configmap app-config

# Patch specific key
kubectl patch configmap app-config \
  -p '{"data":{"DB_HOST":"new-db"}}'

# Replace from file
kubectl replace -f configmap.yaml
```

## Delete ConfigMap

```bash
kubectl delete configmap app-config
```

## Use in Pod - Type A (env)

```yaml
env:
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: DB_HOST
```

## Use in Pod - Type B (volume)

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /etc/config
volumes:
  - name: config-volume
    configMap:
      name: app-config
```

## Use in Pod - Type C (envFrom)

```yaml
envFrom:
  - configMapRef:
      name: app-config
```

## Immutable ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prod-config
immutable: true
data:
  DB_HOST: "prod-db"
```

## Restart Deployment After Config Change

```bash
kubectl rollout restart deployment app-deployment
```

## Verify Environment Variables in Pod

```bash
POD_NAME=$(kubectl get pods -l app=myapp -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- env
```

## Verify Volume Mount in Pod

```bash
kubectl exec $POD_NAME -- ls -la /etc/config
kubectl exec $POD_NAME -- cat /etc/config/nginx.conf
```

## Multi-Environment Pattern

```bash
# Dev
kubectl create cm app-config --from-literal=ENV=dev -n dev

# Staging
kubectl create cm app-config --from-literal=ENV=staging -n staging

# Production
kubectl create cm app-config --from-literal=ENV=production -n production
```

## Best Practices

✅ Use ConfigMaps for non-secret data only
✅ Use Secrets for passwords and tokens
✅ Use immutable ConfigMaps in production
✅ Version your ConfigMaps (app-config-v1, v2)
✅ Document expected keys
✅ Use volume mounts for large config files
✅ Restart pods after env var changes

## Common Errors

### ConfigMap not found
```bash
Error: configmaps "app-config" not found
```
**Solution:** Check namespace and ConfigMap name

### Immutable ConfigMap
```bash
Error: field is immutable
```
**Solution:** Create new version, update deployment

### Size limit exceeded
```bash
Error: ConfigMap size exceeds 1 MiB
```
**Solution:** Split into multiple ConfigMaps or use volume

## Quick Reference

| Command | Description |
|---------|-------------|
| `kubectl create cm` | Create ConfigMap |
| `kubectl get cm` | List ConfigMaps |
| `kubectl describe cm` | Show details |
| `kubectl edit cm` | Edit ConfigMap |
| `kubectl delete cm` | Delete ConfigMap |
| `kubectl rollout restart` | Restart deployment |

## Memory Tricks

**C-E-V**: Command, Environment, Volume (3 consumption types)

**E-E-V**: Explicit env, Everything env, Volume (Type A, C, B)

**3 Questions**:
1. What data? (Secret or non-secret)
2. How many keys? (Few → Type A, Many → Type C)
3. File or var? (File → Type B, Var → Type A/C)
