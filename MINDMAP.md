# ConfigMap Mind Map

```
                            KUBERNETES CONFIGMAP
                                    │
                ┌───────────────────┼───────────────────┐
                │                   │                   │
            WHAT IS IT          WHY EXISTS         HOW IT WORKS
                │                   │                   │
        ┌───────┴───────┐   ┌──────┴──────┐    ┌──────┴──────┐
        │               │   │             │    │             │
    Non-Secret      Stored  │         Without │         With │
    Config Data     in etcd │      ConfigMap  │     ConfigMap│
        │               │   │             │    │             │
    Examples:       Key-Value│         Rebuild│         Edit │
    • DB host           │   │         Image   │      ConfigMap│
    • API URL           │   │         Every   │         +    │
    • Feature flags     │   │         Change  │      Restart │
    • Log level         │   │             │    │             │
                            │             │    │             │
                            │         Slow    │         Fast │
                            │         Risky   │         Safe │
                            │                 │              │
                            └─────────────────┴──────────────┘


                        3 CONSUMPTION TYPES
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    TYPE A: env           TYPE B: volume          TYPE C: envFrom
        │                       │                       │
    Single Key            Keys → Files            All Keys
        ↓                       ↓                       ↓
    Manual Mapping        File System             Auto Inject
        │                       │                       │
    Use When:             Use When:               Use When:
    • 1-2 vars            • Config files          • Many vars
    • Selective           • nginx.conf            • 12-factor
                          • app.properties        • Bulk inject


                        REAL-WORLD SCENARIOS
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Multi-Environment     Feature Flags         Emergency Changes
        │                       │                       │
    Same Image            Toggle Without        DB Migration
    Different Config      Redeploy              30 seconds
        │                       │                       │
    Dev → dev-db          FEATURE_NEW_UI        prod-db →
    Staging → stage-db    true/false            prod-db-v2
    Prod → prod-db        Marketing Control     No Rebuild


                        STORAGE & ARCHITECTURE
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Where Stored          How Injected            Update Behavior
        │                       │                       │
    etcd Database         Kubelet Fetches         env: No auto-update
    /registry/            from API Server         volume: Auto-update
    configmaps/           Injects at              (60 seconds)
    namespace/name        Container Start         Restart needed


                        BEST PRACTICES
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Security              Versioning              Environment
        │                       │                       │
    ConfigMap:            app-config-v1           Dev: Mutable
    Non-secrets           app-config-v2           Prod: Immutable
        │                       │                       │
    Secret:               Rollback                Version Control
    Passwords             Capability              Change Control
    Tokens                                        Audit Trail


                        KEY CONCEPTS
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Separation of         12-Factor App           Cloud-Native
    Concerns              Principle               Design
        │                       │                       │
    Config ≠ Code         Store config            Runtime
    Different             in environment          Configuration
    Lifecycles            not code                not Build-time


                        MEMORY TRICKS
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    C-E-V                 E-E-V                   3 Questions
        │                       │                       │
    Command               Explicit env            1. What data?
    Environment           Everything env          2. How many keys?
    Volume                Volume                  3. File or var?


                        COMPARISON
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Without ConfigMap     With ConfigMap          Result
        │                       │                       │
    Hardcoded in          Stored in               Same Image
    Dockerfile            Kubernetes              All Environments
        │                       │                       │
    Rebuild for           Edit ConfigMap          Fast Updates
    Every Change          + Restart               No CI/CD
        │                       │                       │
    Multiple Images       Single Image            Clean DevOps
    per Environment       + Multiple              Architecture
                          ConfigMaps


                        PRODUCTION PATTERNS
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Immutable             Naming Convention       RBAC
    ConfigMaps            │                       │
        │                 app-config-v1           configmap-reader
    immutable: true       app-config-v2           configmap-admin
    Prevents              Semantic                Least Privilege
    Accidents             Versioning              Access Control


                        TROUBLESHOOTING
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
    Config Not            File Not                Pod Not
    Updating              Mounting                Starting
        │                       │                       │
    Check:                Check:                  Check:
    • Restart pods        • mountPath             • ConfigMap exists
    • ConfigMap name      • subPath               • Key names match
    • Namespace           • Volume name           • RBAC permissions
```

## Ladder Method Summary

### Ladder 1: What It Is
ConfigMap = Non-secret configuration outside container image

### Ladder 2: Why It Exists
Without it: Hardcode → Rebuild → Redeploy (slow)
With it: Edit ConfigMap → Restart (fast)

### Ladder 3: How It Works
- Stored in etcd
- 3 consumption types: env, volume, envFrom
- Kubelet injects at runtime

### Ladder 4: Real Scenario
Same image across Dev/Staging/Prod
Only config differs
Change config without rebuild

## Decision Tree

```
Need to configure app?
    │
    ├─ Is it secret? ──YES──> Use Secret
    │
    └─ NO
        │
        ├─ How many keys?
        │   ├─ 1-2 ──> Type A (env)
        │   └─ Many ──> Type C (envFrom)
        │
        └─ Is it a file?
            └─ YES ──> Type B (volume)
```

## Quick Reference

| Question | Answer |
|----------|--------|
| Where stored? | etcd |
| Max size? | 1 MiB |
| Auto-update? | Volume: Yes, Env: No |
| For secrets? | No, use Secret |
| Immutable? | Optional, recommended for prod |
| Namespace-scoped? | Yes |
