# CI bootstrap: manual steps

These steps require live-cluster write access and GitHub repo settings access
that CI doesn't have. Run them once, in order, as the human operator. This
mirrors the pattern already in use for `biglernet-ai-platform`
(`docs/ci-bootstrap.md` there) — a scoped ServiceAccount token, bound only to
this app's own namespaces, stored as a single base64 kubeconfig secret.

## 1. Create the namespaces

Not part of the CI pipeline on purpose: the CI ServiceAccount's RBAC (step 3
below) is only ever bound per-namespace via `RoleBinding`, so it can't create
namespaces itself, and shouldn't be granted the cluster-wide permission to.

```bash
kubectl apply -f kubernetes/bootstrap/namespaces.yaml
```

This creates `biglernethome-test` and `biglernethome-prod`, both already
labeled `goldilocks.fairwinds.com/enabled: "true"` — Goldilocks (assumed
already installed cluster-wide, per `biglernet-private-cloud/platform/goldilocks`)
picks these up automatically; no separate opt-in step needed here.

## 2. Scoped ServiceAccount + RBAC for the deploy pipeline

```bash
# Dedicated namespace + ServiceAccount for the CI identity
kubectl create namespace biglernet-homepage-ci
kubectl create serviceaccount biglernet-homepage-ci -n biglernet-homepage-ci

# ClusterRole defining what the deployer can do (only ever bound per-namespace
# below — this does NOT grant cluster-wide access by itself). Scoped to just
# what `kubectl apply -k` + `kubectl set image` + `kubectl rollout status`
# need for this app's Deployment/Service/Ingress — no ConfigMaps, Secrets,
# PVCs, or CRDs, since the site has none.
cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: biglernet-homepage-deployer
rules:
  - apiGroups: ["", "apps", "networking.k8s.io"]
    resources:
      - pods
      - pods/log
      - services
      - events
      - deployments
      - replicasets
      - ingresses
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
EOF

# Bind it in this app's two namespaces only
for ns in biglernethome-test biglernethome-prod; do
  kubectl create rolebinding biglernet-homepage-ci-deployer \
    --clusterrole=biglernet-homepage-deployer \
    --serviceaccount=biglernet-homepage-ci:biglernet-homepage-ci \
    -n "$ns"
done

# Long-lived token Secret (K8s 1.24+ no longer auto-creates these)
cat <<'EOF' | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: biglernet-homepage-ci-token
  namespace: biglernet-homepage-ci
  annotations:
    kubernetes.io/service-account.name: biglernet-homepage-ci
type: kubernetes.io/service-account-token
EOF
```

## 3. Store the credential as a GitHub Actions secret

```bash
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA=$(kubectl get secret biglernet-homepage-ci-token -n biglernet-homepage-ci -o jsonpath='{.data.ca\.crt}')
TOKEN=$(kubectl get secret biglernet-homepage-ci-token -n biglernet-homepage-ci -o jsonpath='{.data.token}' | base64 -d)

cat > biglernet-homepage-ci.kubeconfig <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: ${CA}
    server: ${SERVER}
  name: biglernet
contexts:
- context:
    cluster: biglernet
    namespace: biglernethome-test
    user: biglernet-homepage-ci
  name: biglernet-homepage-ci
current-context: biglernet-homepage-ci
users:
- name: biglernet-homepage-ci
  user:
    token: ${TOKEN}
EOF

base64 -w0 biglernet-homepage-ci.kubeconfig
```

Store the base64 output as a repo secret named **`HOMEPAGE_KUBECONFIG`**:

```bash
gh secret set HOMEPAGE_KUBECONFIG --repo <owner>/biglernet-homepage
```

(or via GitHub → Settings → Secrets and variables → Actions). `deploy.yml`
decodes this secret directly into `~/.kube/config`.

**Delete the local `biglernet-homepage-ci.kubeconfig` file afterward** — don't
leave it on disk or commit it (it's covered by `.gitignore` via `*.kubeconfig`,
but don't rely on that alone for a credential file).

## 4. Make the GHCR package pullable by the cluster

The deploy workflow pushes to `ghcr.io/<repo-owner>/biglernet-homepage`
using the built-in `GITHUB_TOKEN` — no extra registry secret needed for
*pushing*. But GHCR images are **private by default**, and the cluster has no
GHCR pull credentials configured. Since this is a public marketing site with
nothing sensitive in the image, the simplest fix is to make the package
public once, after the first push:

GitHub → your org/user → **Packages** → `biglernet-homepage` → **Package
settings** → Danger Zone → **Change visibility** → Public.

If you'd rather keep it private, create an `imagePullSecrets` entry instead
(a PAT with `read:packages`, wired as a `kubernetes.io/dockerconfigjson`
Secret in both `biglernethome-test` and `biglernethome-prod`, referenced
from `kubernetes/base/deployment.yaml`) — not set up here since it adds an
extra secret to rotate for no real benefit on this app.

## When a new namespace is created

1. `kubectl create namespace <name>`
2. Add a matching RoleBinding for the CI ServiceAccount, following the
   pattern in step 2 above (the `for ns in ...` loop) — either append the new
   name to that loop and re-run it, or run the `kubectl create rolebinding`
   command standalone for just the new namespace.
