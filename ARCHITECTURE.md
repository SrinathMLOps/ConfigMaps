# ConfigMap Architecture Deep Dive

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                       │
│                                                              │
│  ┌──────────────┐         ┌──────────────┐                 │
│  │   Developer  │────────▶│  API Server  │                 │
│  │   (kubectl)  │         │              │                 │
│  └──────────────┘         └──────┬───────┘                 │
│                                   │                          │
│                                   ▼                          │
│                          ┌──────────────┐                   │
│                          │     etcd     │                   │
│                          │  (Storage)   │                   │
│                          └──────┬───────┘                   │
│                                   │                          │
│                                   ▼                          │
│  ┌────────────────────────────────────────────────┐        │
│  │              Worker Nodes                       │        │
│  │                                                  │        │
│  │  ┌──────────┐         ┌──────────────────┐    │        │
│  │  │ Kubelet  │────────▶│  ConfigMap Data  │    │        │
│  │  └────┬─────┘         └──────────────────┘    │        │
│  │       │                                         │        │
│  │       ▼                                         │        │
│  │  ┌─────────────────────────────────────┐      │        │
│  │  │           Pod                        │      │        │
│  │  │  ┌────────────────────────────┐     │      │        │
│  │  │  │      Container              │     │      │        │
│  │  │  │                             │     │      │        │
│  │  │  │  ENV: DB_HOST=prod-db      │     │      │        │
│  │  │  │  ENV: API_URL=...          │     │      │        │
│  │  │  │                             │     │      │        │
│  │  │  │  /etc/config/               │     │      │        │
│  │  │  │    └── nginx.conf           │     │      │        │
│  │  │  └────────────────────────────┘     │      │        │
│  │  └─────────────────────────────────────┘      │        │
│  └────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

## ConfigMap Storage in etcd

```
etcd Key-Value Store
├── /registry/
│   ├── configmaps/
│   │   ├── default/
│   │   │   ├── app-config
│   │   │   └── nginx-config
│   │   ├── production/
│   │   │   └── prod-config
│   │   └── staging/
│   │       └── staging-config
```

## The 3 Consumption Patterns

### Type A: Environment Variables (env)

```
ConfigMap                    Pod
┌──────────────┐            ┌─────────────────┐
│ DB_HOST:     │            │  Container      │
│  prod-db     │───────────▶│  ENV:           │
│              │            │   DB_HOST=      │
│ API_URL:     │            │   prod-db       │
│  https://... │            │                 │
└──────────────┘            └─────────────────┘
```

### Type B: Volume Mount (files)

```
ConfigMap                    Pod
┌──────────────┐            ┌─────────────────┐
│ nginx.conf:  │            │  Container      │
│  user nginx; │───────────▶│  /etc/config/   │
│  worker...   │            │   nginx.conf    │
│              │            │                 │
└──────────────┘            └─────────────────┘
```

### Type C: Bulk Injection (envFrom)

```
ConfigMap                    Pod
┌──────────────┐            ┌─────────────────┐
│ DB_HOST      │            │  Container      │
│ DB_PORT      │            │  ENV:           │
│ API_URL      │───────────▶│   DB_HOST       │
│ LOG_LEVEL    │            │   DB_PORT       │
│ APP_MODE     │            │   API_URL       │
│ ...          │            │   LOG_LEVEL     │
└──────────────┘            │   APP_MODE      │
                            └─────────────────┘
```

## Multi-Environment Architecture

```
                    Same Docker Image
                      myapp:v1.0.0
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌─────────┐        ┌─────────┐       ┌─────────┐
   │   Dev   │        │ Staging │       │  Prod   │
   │ Namespace│       │Namespace│       │Namespace│
   └────┬────┘        └────┬────┘       └────┬────┘
        │                  │                  │
        ▼                  ▼                  ▼
   ConfigMap          ConfigMap          ConfigMap
   ┌─────────┐        ┌─────────┐       ┌─────────┐
   │DB: dev  │        │DB: stage│       │DB: prod │
   │LOG:debug│        │LOG: info│       │LOG: warn│
   └─────────┘        └─────────┘       └─────────┘
```

## ConfigMap Lifecycle

```
1. CREATE
   kubectl create configmap my-config --from-literal=KEY=VALUE
                    ↓
2. STORE
   API Server → etcd (/registry/configmaps/namespace/name)
                    ↓
3. REFERENCE
   Deployment references ConfigMap in Pod spec
                    ↓
4. INJECT
   Kubelet fetches from API Server → Injects into container
                    ↓
5. UPDATE
   kubectl edit configmap my-config
                    ↓
6. RESTART
   kubectl rollout restart deployment (for env vars)
   Auto-update (for volume mounts, ~60 seconds)
```

## Data Flow

```
┌──────────────────────────────────────────────────────────┐
│ 1. Developer creates ConfigMap                           │
│    kubectl create configmap app-config                   │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ 2. API Server validates and stores in etcd               │
│    /registry/configmaps/default/app-config               │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ 3. Deployment references ConfigMap                       │
│    envFrom: configMapRef: name: app-config               │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ 4. Scheduler places Pod on Node                          │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ 5. Kubelet on Node:                                      │
│    - Reads Pod spec                                      │
│    - Sees ConfigMap reference                            │
│    - Calls API Server                                    │
│    - Fetches ConfigMap data                              │
└────────────────────┬─────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────┐
│ 6. Kubelet injects into container:                       │
│    - As environment variables (env/envFrom)              │
│    - As files in volume (volumeMount)                    │
└──────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Configuration Data                    │
│                                                          │
│  ┌──────────────┐              ┌──────────────┐        │
│  │  ConfigMap   │              │   Secret     │        │
│  │              │              │              │        │
│  │ • Plain text │              │ • Base64     │        │
│  │ • Visible    │              │ • Encrypted  │        │
│  │ • Non-secret │              │ • Sensitive  │        │
│  │              │              │              │        │
│  │ Examples:    │              │ Examples:    │        │
│  │ - DB host    │              │ - Passwords  │        │
│  │ - API URL    │              │ - Tokens     │        │
│  │ - Log level  │              │ - Certs      │        │
│  └──────────────┘              └──────────────┘        │
└─────────────────────────────────────────────────────────┘
```

## Performance Considerations

### ConfigMap Size Limits
- Maximum size: 1 MiB per ConfigMap
- Stored in etcd (limited capacity)
- Large configs → use volume mounts

### Update Propagation
- **env/envFrom**: No auto-update (requires pod restart)
- **volumeMount**: Auto-updates (~60 seconds)
- Application must support config reload

## RBAC Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    RBAC Permissions                      │
│                                                          │
│  Role: configmap-reader                                 │
│  ┌────────────────────────────────────────────┐        │
│  │ apiGroups: [""]                             │        │
│  │ resources: ["configmaps"]                   │        │
│  │ verbs: ["get", "list"]                      │        │
│  └────────────────────────────────────────────┘        │
│                                                          │
│  Role: configmap-admin                                  │
│  ┌────────────────────────────────────────────┐        │
│  │ apiGroups: [""]                             │        │
│  │ resources: ["configmaps"]                   │        │
│  │ verbs: ["*"]                                │        │
│  └────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────┘
```

## Comparison: With vs Without ConfigMap

### Without ConfigMap (Hardcoded)
```
Code Change → Build Image → Push Registry → Update Deployment
   ↓             ↓              ↓                ↓
 5 min        10 min         5 min           5 min
                    Total: 25 minutes
```

### With ConfigMap
```
Edit ConfigMap → Restart Pods
      ↓              ↓
   10 sec         20 sec
        Total: 30 seconds
```

## Best Practices Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Environment Strategy                    │
│                                                          │
│  Development                                             │
│  ├── Mutable ConfigMaps                                 │
│  ├── Frequent changes allowed                           │
│  └── Debug logging enabled                              │
│                                                          │
│  Staging                                                 │
│  ├── Mutable ConfigMaps                                 │
│  ├── Production-like config                             │
│  └── Info logging                                       │
│                                                          │
│  Production                                              │
│  ├── Immutable ConfigMaps                               │
│  ├── Versioned (app-config-v1, v2...)                   │
│  ├── Change control required                            │
│  └── Warn/Error logging only                            │
└─────────────────────────────────────────────────────────┘
```
