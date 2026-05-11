Kubernetes Secrets Hands-On Lab

This section covers:

Opaque Secrets
TLS Secrets
Docker Registry Secrets
Using Secrets inside Pods
Verifying and debugging Secrets
1. Create Secrets Directory
mkdir -p secrets
2. Create Opaque Secret

Generate Secret YAML imperatively:

kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASSWORD='S3cr3t!' \
  --dry-run=client -o yaml > secrets/secret-opaque-PLACEHOLDER.yaml

Check generated YAML:

cat secrets/secret-opaque-PLACEHOLDER.yaml

Apply Secret:

kubectl apply -f secrets/secret-opaque-PLACEHOLDER.yaml

Verify:

kubectl get secrets

Describe Secret:

kubectl describe secret db-credentials

View encoded values:

kubectl get secret db-credentials -o yaml

Decode username:

kubectl get secret db-credentials -o jsonpath='{.data.DB_USER}' | base64 -d

Decode password:

kubectl get secret db-credentials -o jsonpath='{.data.DB_PASSWORD}' | base64 -d
3. Create TLS Secret

Generate self-signed certificate:

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout secrets/tls.key \
  -out secrets/tls.crt \
  -subj "/CN=myapp.local"

Create TLS Secret:

kubectl create secret tls myapp-tls \
  --cert=secrets/tls.crt \
  --key=secrets/tls.key

Verify:

kubectl describe secret myapp-tls

Check Secret type:

kubectl get secret myapp-tls

Expected type:

kubernetes.io/tls
4. Create Docker Registry Secret

Used for pulling private container images.

Create registry secret:

kubectl create secret docker-registry regcred \
  --docker-server=ghcr.io \
  --docker-username=YOUR_GITHUB_USER \
  --docker-password=YOUR_GITHUB_PAT \
  --docker-email=you@example.com

Verify:

kubectl get secret regcred

Describe:

kubectl describe secret regcred

Expected type:

kubernetes.io/dockerconfigjson
5. Use imagePullSecrets in Pod
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

Apply:

kubectl apply -f pod.yaml
6. Use Secret as Environment Variable

Create Pod manifest:

secrets/pod-secret-env.yaml

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

Apply:

kubectl apply -f secrets/pod-secret-env.yaml

Check Pod:

kubectl get pods

View logs:

kubectl logs pod-secret-env

Expected output:

admin
7. Common Secret Debug Commands

List Secrets:

kubectl get secrets

Describe Secret:

kubectl describe secret db-credentials

Get YAML:

kubectl get secret db-credentials -o yaml

Decode values:

kubectl get secret db-credentials -o jsonpath='{.data.DB_USER}' | base64 -d

Check Pod events:

kubectl describe pod pod-secret-env

