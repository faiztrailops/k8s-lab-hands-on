# Kubernetes RBAC Hands-On Lab

This lab covers:

- Namespace creation
- ServiceAccounts
- Roles
- RoleBindings
- Kubeconfig access
- RBAC permission testing

---

# 1. Create Namespace + ServiceAccount

File:

`rbac/namespace.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev-team
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: dev-user
  namespace: dev-team
```

Apply:

```bash
kubectl apply -f rbac/namespace.yaml
```

Verify:

```bash
kubectl get ns
kubectl get sa -n dev-team
```

---

# 2. Create Role

File:

`rbac/role.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: dev-team

rules:
- apiGroups: [""]
  resources: ["pods", "pods/log"]
  verbs: ["get", "list", "watch"]
```

Apply:

```bash
kubectl apply -f rbac/role.yaml
```

Verify:

```bash
kubectl describe role pod-reader -n dev-team
```

Allowed:

- get pods
- list pods
- watch pods
- read pod logs

Not allowed:

- nodes
- secrets
- namespaces
- deployments

---

# 3. Create RoleBinding

File:

`rbac/rolebinding.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-user-binding
  namespace: dev-team

subjects:
- kind: ServiceAccount
  name: dev-user
  namespace: dev-team

roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Apply:

```bash
kubectl apply -f rbac/rolebinding.yaml
```

Verify:

```bash
kubectl describe rolebinding dev-user-binding -n dev-team
```

---

# 4. Generate ServiceAccount Token

Kubernetes 1.24+:

```bash
kubectl create token dev-user -n dev-team
```

---

# 5. Configure kubeconfig

Add credentials:

```bash
kubectl config set-credentials dev-user \
  --token=$(kubectl create token dev-user -n dev-team)
```

Create context:

```bash
kubectl config set-context dev-context \
  --cluster=kubernetes \
  --namespace=dev-team \
  --user=dev-user
```

Use context:

```bash
kubectl config use-context dev-context
```

Verify current context:

```bash
kubectl config current-context
```

---

# 6. Test RBAC Permissions

These SHOULD work:

```bash
kubectl get pods -n dev-team
kubectl logs <pod-name> -n dev-team
```

These SHOULD FAIL:

```bash
kubectl get nodes
kubectl get secrets
kubectl get pods -n default
```

Expected error:

```text
Error from server (Forbidden)
```

---

# 7. Debug Commands

List Roles:

```bash
kubectl get roles -n dev-team
```

List RoleBindings:

```bash
kubectl get rolebindings -n dev-team
```

Describe ServiceAccount:

```bash
kubectl describe sa dev-user -n dev-team
```

Check current context:

```bash
kubectl config get-contexts
```

View kubeconfig:

```bash
kubectl config view
```

---

# 8. Cleanup

Delete RoleBinding:

```bash
kubectl delete -f rbac/rolebinding.yaml
```

Delete Role:

```bash
kubectl delete -f rbac/role.yaml
```

Delete Namespace:

```bash
kubectl delete -f rbac/namespace.yaml
```

---

# 9. Recommended Repository Structure

```text
rbac/
├── README.md
├── namespace.yaml
├── role.yaml
└── rolebinding.yaml
```
