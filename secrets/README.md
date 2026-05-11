# Kubernetes Secrets Hands-On Lab

This lab covers:

- Opaque Secrets
- TLS Secrets
- Docker Registry Secrets
- Using Secrets inside Pods
- Verifying and debugging Secrets

---

# 1. Create Opaque Secret

File:

`secrets/secret-opaque.yaml`

Generate Secret YAML:

```bash
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD='S3cr3t!' \
  --dry-run=client -o yaml > secrets/secret-opaque.yaml
```

Apply:

```bash
kubectl apply -f secrets/secret-opaque.yaml
```

Verify:

```bash
kubectl get secrets
kubectl describe secret db-credentials
```

---

# 2. View Secret Values

View YAML:

```bash
kubectl get secret db-credentials -o yaml
```

Decode username:

```bash
kubectl get secret db-credentials \
  -o jsonpath='{.data.DB_USER}' | base64 -d
```

Decode password:

```bash
kubectl get secret db-credentials \
  -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
```

---

# 3. Create TLS Secret

Generate self-signed certificate:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout secrets/tls.key \
  -out secrets/tls.crt \
  -subj "/CN=myapp.local"
```

Create TLS Secret:

```bash
kubectl create secret tls myapp-tls \
  --cert=secrets/tls.crt \
  --key=secrets/tls.key
```

Verify:

```bash
kubectl get secret myapp-tls
kubectl describe secret myapp-tls
```

Expected type:

```text
kubernetes.io/tls
```

---

# 4. Create Docker Registry Secret

Used for pulling private container images.

```bash
kubectl create secret docker-registry regcred \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USER \
  --docker-password=YOUR_TOKEN \
  --docker-email=you@example.com
```

Verify:

```bash
kubectl get secret regcred
kubectl describe secret regcred
```

Expected type:

```text
kubernetes.io/dockerconfigjson
```

---

# 5. Use imagePullSecrets

Example Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-image-pod

spec:
  imagePullSecrets:
  - name: regcred

  containers:
  - name: app
    image: ghcr.io/YOUR_GITHUB_USER/myapp:latest
```

Apply:

```bash
kubectl apply -f pod.yaml
```

---

# 6. Use Secret as Environment Variable

File:

`secrets/pod-secret-env.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-secret-env

spec:
  containers:
  - name: app
    image: busybox
    command: ["sh","-c","echo $DB_USER && sleep 60"]

    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: db-credentials
          key: DB_USER

  restartPolicy: Never
```

Apply:

```bash
kubectl apply -f secrets/pod-secret-env.yaml
```

Check Pod:

```bash
kubectl get pods
```

View logs:

```bash
kubectl logs pod-secret-env
```

Expected output:

```text
admin
```

---

# 7. Common Secret Debug Commands

List Secrets:

```bash
kubectl get secrets
```

Describe Secret:

```bash
kubectl describe secret db-credentials
```

Get YAML:

```bash
kubectl get secret db-credentials -o yaml
```

Check Pod events:

```bash
kubectl describe pod pod-secret-env
```

---

# 8. Recommended Repository Structure

```text
secrets/
├── README.md
├── secret-opaque.yaml
├── pod-secret-env.yaml
├── tls.crt
└── tls.key
```
