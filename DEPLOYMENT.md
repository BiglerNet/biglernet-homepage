# BiglerNet Homepage Deployment Guide

This guide covers building, deploying, and managing the BiglerNet homepage — a
static HTML/CSS/JS site served by a minimal ASP.NET Core 10.0 static-file
host (no server-side rendering, no API, no database).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Automated Deployment (CI/CD)](#automated-deployment-cicd)
3. [Building the Docker Image Manually](#building-the-docker-image-manually)
4. [Deploying to Kubernetes Manually](#deploying-to-kubernetes-manually)
5. [Environments](#environments)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

- **Docker** (v20+ recommended, with Buildx for multi-arch builds)
- **kubectl** (v1.27+ recommended — needs native Kustomize support for `-k`)
- Access to a Kubernetes cluster with Traefik ingress controller and a
  cluster-wide TLS issuer

### Required Kubernetes Resources

- **Namespaces**: `biglernet-home-test`, `biglernet-home-prod` — created once
  via `kubectl apply -f kubernetes/bootstrap/namespaces.yaml` (see
  [`docs/ci-bootstrap.md`](docs/ci-bootstrap.md))
- **Ingress Controller**: Traefik with `websecure` entrypoint
- **TLS**: Issued automatically by the cluster's TLS issuer for
  `biglernet.com`, `www.biglernet.com`, and `homepage-test.biglernet.com`

## Automated Deployment (CI/CD)

Every push to `main` triggers `.github/workflows/deploy.yml`, which:

1. Builds a multi-arch (`linux/amd64` + `linux/arm64`) image and pushes it to
   `ghcr.io/<owner>/biglernet-homepage`
2. Deploys it to `biglernet-home-test`, waits for rollout, and runs a smoke
   check against `https://homepage-test.biglernet.com`
3. On success, automatically deploys the same image to `biglernet-home-prod`
   and smoke-checks `https://biglernet.com`

Deploy jobs run on the org's self-hosted ARC runner set
(`biglernet-arc-runner-set`) so they can reach the private cluster directly —
no cluster ingress from the public internet is required for deploys. The
image build itself runs on a GitHub-hosted runner, since it doesn't need
cluster access.

To redeploy an existing image (e.g. a rollback) without rebuilding, run the
workflow manually via **Actions → Build & Deploy → Run workflow** and supply
the `image_tag` input (e.g. `sha-abc1234`).

This depends on one-time manual cluster setup — see
[`docs/ci-bootstrap.md`](docs/ci-bootstrap.md) for creating the namespaces,
the scoped CI ServiceAccount/RBAC, and the `HOMEPAGE_KUBECONFIG` GitHub
secret.

## Building the Docker Image Manually

```bash
docker build -t biglernet-homepage:local .
```

The Dockerfile is a multi-stage build — `dotnet publish` runs inside the
build stage, so no separate publish step is needed. To build and push
multi-arch manually (matching what CI does):

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/<owner>/biglernet-homepage:manual \
  --push .
```

### Build Verification

```bash
docker run -d -p 8080:8080 --name biglernet-test biglernet-homepage:local
curl http://localhost:8080
docker stop biglernet-test && docker rm biglernet-test
```

## Deploying to Kubernetes Manually

Manifests are organized with Kustomize: `kubernetes/base/` holds the shared
Deployment + Service, and `kubernetes/overlays/test/` /
`kubernetes/overlays/prod/` layer on the namespace, replica count, and
Ingress host(s) for each environment.

```bash
# Preview the rendered manifests for an environment
kubectl kustomize kubernetes/overlays/test

# Apply
kubectl apply -k kubernetes/overlays/test

# Point the deployment at a specific image tag
kubectl set image deployment/biglernet-website \
  website=ghcr.io/<owner>/biglernet-homepage:<tag> \
  -n biglernet-home-test

kubectl rollout status deployment/biglernet-website -n biglernet-home-test
```

Swap `test` for `prod` (and the namespace) to deploy to production the same
way.

### Verify Deployment

```bash
kubectl get pods -n biglernet-home-prod
kubectl get deployment -n biglernet-home-prod
kubectl get service -n biglernet-home-prod
kubectl get ingress -n biglernet-home-prod
kubectl logs -n biglernet-home-prod -l app=biglernet-website -f
```

## Environments

| | Test | Production |
|---|---|---|
| Namespace | `biglernet-home-test` | `biglernet-home-prod` |
| Replicas | 1 | 3 |
| Host(s) | `homepage-test.biglernet.com` | `biglernet.com`, `www.biglernet.com` |
| Overlay | `kubernetes/overlays/test/` | `kubernetes/overlays/prod/` |

### Resource Limits

Set in `kubernetes/base/deployment.yaml` (shared by both environments):

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

## Troubleshooting

### Pod CrashLoopBackOff

```bash
kubectl logs -n biglernet-home-prod <pod-name>
kubectl describe pod -n biglernet-home-prod <pod-name>
```

### Ingress Not Routing Traffic

**Symptoms**: HTTP 502 or connection refused.

```bash
kubectl get ingress -n biglernet-home-prod
kubectl get endpoints -n biglernet-home-prod
kubectl logs -n traefik <traefik-pod-name>
```

### Image Pull Error (`ImagePullBackOff` / `ErrImagePull`)

GHCR packages are private by default. If the cluster can't pull the image,
either make the package public (see `docs/ci-bootstrap.md` step 4) or wire up
an `imagePullSecrets` entry.

```bash
docker pull ghcr.io/<owner>/biglernet-homepage:latest
kubectl describe pod -n biglernet-home-prod <pod-name>
```

### 404 Not Found on Static Files

```bash
kubectl exec -n biglernet-home-prod <pod-name> -- ls -la /app/wwwroot
```

### Debugging Commands

```bash
kubectl get all -n biglernet-home-prod
kubectl top pods -n biglernet-home-prod
kubectl port-forward -n biglernet-home-prod svc/biglernet-website-service 8080:80
```

### Rolling Back

```bash
kubectl rollout undo deployment/biglernet-website -n biglernet-home-prod
```

Or re-run the deploy workflow with `image_tag` set to a previous known-good
tag (see [Automated Deployment](#automated-deployment-cicd)).
