# Kubernetes ConfigMaps Hands-On Lab

This guide covers:

* Creating ConfigMaps manually
* Creating ConfigMaps from env files
* Using ConfigMaps inside Pods
* Verifying ConfigMap data
* Debugging ConfigMaps

---

# 1. Create Project Structure

```bash
mkdir -p configmaps
```

---

# 2. Create Literal ConfigMap

Create file:

`configmaps/cm-literal.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-literal

data:
  APP_ENV: "production"
  LOG_LEVEL: "info"
  MAX_RETRIES: "3"
```

Apply ConfigMap:

```bash
kubectl apply -f configmaps/cm-literal.yaml
```

Verify:

```bash
kubectl get configmap
```

Detailed output:

```bash
kubectl get configmap app-config-literal -o yaml
```

Describe:

```bash
kubectl describe cm app-config-literal
```

---

# 3. Create ConfigMap From Env File

Create env file:

`configmaps/app.env`

```env
DB_HOST=postgres.default.svc.cluster.local
DB_PORT=5432
DB_NAME=myapp
```

Generate ConfigMap YAML:

```bash
kubectl create configmap app-config-env \
  --from-env-file=configmaps/app.env \
  --dry-run=client -o yaml > configmaps/cm-from-env.yaml
```

Check generated YAML:

```bash
cat configmaps/cm-from-env.yaml
```

Apply:

```bash
kubectl apply -f configmaps/cm-from-env.yaml
```

Verify:

```bash
kubectl get cm
```

Describe:

```bash
kubectl describe cm app-config-env
```

---

# 4. Use ConfigMaps Inside Pod

Create Pod manifest:

`configmaps/pod-envfrom.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: cm-envfrom-pod

spec:
  containers:
  - name: app
    image: busybox
    command: ["sh", "-c", "env && sleep 3600"]

    envFrom:
    - configMapRef:
        name: app-config-literal

    - configMapRef:
        name: app-config-env

  restartPolicy: Never
```

Apply Pod:

```bash
kubectl apply -f configmaps/pod-envfrom.yaml
```

Check Pod:

```bash
kubectl get pods
```

View logs:

```bash
kubectl logs cm-envfrom-pod
```

Expected variables:

```text
APP_ENV=production
LOG_LEVEL=info
MAX_RETRIES=3
DB_HOST=postgres.default.svc.cluster.local
DB_PORT=5432
DB_NAME=myapp
```

Exec into Pod:

```bash
kubectl exec -it cm-envfrom-pod -- sh
```

Check environment variables:

```bash
env
```

Filter specific variables:

```bash
kubectl exec cm-envfrom-pod -- env | grep -E "APP_ENV|DB_HOST"
```

---

# 5. Delete Resources

Delete Pod:

```bash
kubectl delete -f configmaps/pod-envfrom.yaml
```

Delete ConfigMaps:

```bash
kubectl delete -f configmaps/cm-literal.yaml
kubectl delete -f configmaps/cm-from-env.yaml
```

---

# 6. Common Debug Commands

List ConfigMaps:

```bash
kubectl get cm
```

Describe ConfigMap:

```bash
kubectl describe cm app-config-literal
```

Get YAML:

```bash
kubectl get cm app-config-env -o yaml
```

Check Pod events:

```bash
kubectl describe pod cm-envfrom-pod
```

Check container logs:

```bash
kubectl logs cm-envfrom-pod
```

---

# 7. Recommended Repository Structure

```text
k8s-lab-hands-on/
├── README.md
├── configmaps/
│   ├── README.md
│   ├── app.env
│   ├── cm-literal.yaml
│   ├── cm-from-env.yaml
│   └── pod-envfrom.yaml
├── secrets/
├── rbac/
├── jobs/
└── cronjobs/
```

Yes — keeping separate README files for each topic is a professional approach.

Example:

* `configmaps/README.md`
* `secrets/README.md`
* `rbac/README.md`
* `jobs/README.md`
* `cronjobs/README.md`

This makes the repository cleaner and easier to learn topic-by-topic.

