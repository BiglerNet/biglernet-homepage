# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Run locally
```bash
dotnet run --project src/BiglerNet.Website/BiglerNet.Website.csproj
```
The app listens on `http://localhost:5188` by default (see `src/BiglerNet.Website/Properties/launchSettings.json`).

### Build the Docker image
```bash
docker build -t biglernet-homepage:local .
```
The Dockerfile is a multi-stage build (`dotnet publish` happens inside the build stage) — no separate publish step needed. Multi-arch (`linux/amd64,linux/arm64`) builds are only done in CI, via `docker buildx`.

### Run the Docker image locally
```bash
docker run -d -p 8080:8080 --name biglernet-test biglernet-homepage:local
# Test at http://localhost:8080
docker stop biglernet-test && docker rm biglernet-test
```

### Deploy manually
Normally deploys happen via GitHub Actions (`.github/workflows/deploy.yml`) on push to `main`. To apply manifests by hand:
```bash
kubectl apply -k kubernetes/overlays/test   # or overlays/prod
kubectl set image deployment/biglernet-website website=ghcr.io/<owner>/biglernet-homepage:<tag> -n biglernet-home-test
```
See `docs/ci-bootstrap.md` for the one-time cluster/secret setup this depends on.

## Architecture

This is a **static website** (HTML/CSS/JS) hosted by a minimal ASP.NET Core 10.0 app that acts purely as a static file server. There is no server-side rendering, no API, and no database.

### ASP.NET Core host (`src/BiglerNet.Website/`)
`Program.cs` is intentionally minimal — it only wires up `UseDefaultFiles` (serving `index.html` as the root), `UseStaticFiles`, and a fallback exception handler for production. Static website content (HTML, CSS, JS, images) lives in `src/BiglerNet.Website/wwwroot/`.

### Deployment stack
- **Container**: Alpine-based `mcr.microsoft.com/dotnet/aspnet:10.0` image, built multi-arch (amd64 + arm64)
- **Registry**: `ghcr.io/<owner>/biglernet-homepage`
- **Orchestration**: Kubernetes, via Kustomize overlays in `kubernetes/`:
  - `kubernetes/base/` — shared Deployment + Service
  - `kubernetes/overlays/test/` — namespace `biglernet-home-test`, 1 replica, host `homepage-test.biglernet.com`
  - `kubernetes/overlays/prod/` — namespace `biglernet-home-prod`, 3 replicas, hosts `biglernet.com` / `www.biglernet.com`
  - `kubernetes/bootstrap/namespaces.yaml` — applied once by hand, not by CI (see `docs/ci-bootstrap.md`)
- **Ingress**: Traefik with TLS
- **CI/CD**: GitHub Actions (`.github/workflows/`) — `ci.yml` builds on every push/PR; `deploy.yml` builds & pushes a multi-arch image on push to `main`, deploys to test, smoke-checks, then auto-promotes to prod. Deploy jobs run on the org's self-hosted ARC runner set (`biglernet-arc-runner-set`) so they can reach the private cluster; the image build itself runs on a GitHub-hosted runner.
