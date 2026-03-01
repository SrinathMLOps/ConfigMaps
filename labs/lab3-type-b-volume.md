# Lab 3: ConfigMap Type B - Volume Mounts

## Objective
Learn to mount ConfigMap keys as files in a container.

## Scenario
Deploy an Nginx server with custom configuration file.

## Steps

### 1. Create nginx.conf File

Already created in `../examples/nginx.conf`

### 2. Create ConfigMap from File

```bash
kubectl create configmap nginx-config \
  --from-file=../examples/nginx.conf
```

### 3. Verify ConfigMap

```bash
kubectl describe configmap nginx-config
```

### 4. Deploy Nginx with Volume Mount

```bash
kubectl apply -f ../manifests/deployment-volume.yaml
```

### 5. Verify File Mount

```bash
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD_NAME -- cat /etc/nginx/nginx.conf
```

## Expected Output

You should see the nginx.conf content mounted as a file.

## Key Concepts

- **Keys become files**: Each ConfigMap key creates a file
- **File path**: mountPath + key name = full file path
- **Auto-update**: Files update automatically (within ~60 seconds)
- **Best for**: Configuration files, properties files

## File Structure Inside Container

```
/etc/nginx/
  └── nginx.conf  (from ConfigMap key)
```

## Exercise

1. Update nginx.conf in ConfigMap
2. Wait 60 seconds
3. Verify file updated automatically (no pod restart needed)

```bash
kubectl edit configmap nginx-config
# Wait 60 seconds
kubectl exec $POD_NAME -- cat /etc/nginx/nginx.conf
```

## Next Steps
Proceed to [Lab 4: Type C - Bulk Injection](./lab4-type-c-envfrom.md)
