## ADDED Requirements

### Requirement: Docker Containerization
The system SHALL provide a multi-stage Dockerfile that containerizes the ASP.NET Core static-file host, built for both `linux/amd64` and `linux/arm64`.

The image is published to `ghcr.io/<owner>/biglernet-homepage`.

#### Scenario: Docker build succeeds
- **WHEN** user runs `docker build -t biglernet-homepage:local .`
- **THEN** a Docker image is created with the static files served by the ASP.NET Core host, with no separate `dotnet publish` step required beforehand

#### Scenario: Container starts successfully
- **WHEN** user runs `docker run -p 8080:8080 biglernet-homepage:local`
- **THEN** the application is accessible at http://localhost:8080

### Requirement: Kubernetes Deployment
The system SHALL provide Kustomize-based Kubernetes manifests to deploy the application to a Kubernetes cluster, with a shared base and per-environment overlays for test and production.

#### Scenario: Deployment manifest is valid
- **WHEN** user applies an overlay with `kubectl apply -k kubernetes/overlays/prod`
- **THEN** a Kubernetes Deployment resource is created with the `website` container in namespace `biglernet-home-prod` at 3 replicas

#### Scenario: Service exposes the application
- **WHEN** the overlay is applied
- **THEN** a Kubernetes Service resource is created to expose the deployment internally

### Requirement: External Access via Ingress
The system SHALL provide an Ingress manifest per environment to expose the application externally.

- Production listens on: biglernet.com, www.biglernet.com
- Test listens on: homepage-test.biglernet.com
- TLS is enabled; the ingress class is traefik
- No TLS secret name is specified — the cluster issues a certificate using a cluster-wide issuer

#### Scenario: Ingress is configured
- **WHEN** user applies `kubectl apply -k kubernetes/overlays/prod`
- **THEN** a Kubernetes Ingress resource is created with host-based routing to the service for both production hostnames

### Requirement: Multi-arch Docker Build
The Dockerfile SHALL use a multi-stage build, where the build stage runs `dotnet publish` (no runtime identifier, so the output is architecture-agnostic) and the final stage copies that output into the target-architecture ASP.NET Core runtime image.

#### Scenario: Build stage completes
- **WHEN** the Dockerfile reaches the build stage
- **THEN** the published `.dll` output is generated in the build container using the .NET SDK image

#### Scenario: Runtime stage is minimal
- **WHEN** the Dockerfile reaches the runtime stage
- **THEN** only the published output is copied onto the Alpine-based ASP.NET Core runtime image

### Requirement: Environment-Scoped Configuration
The Kubernetes manifests SHALL allow per-environment configuration (namespace, replica count, ingress host) via Kustomize overlays, without duplicating the shared Deployment/Service definitions.

#### Scenario: Replicas are configurable per environment
- **WHEN** `kubernetes/overlays/test` is applied
- **THEN** the Deployment has 1 replica
- **WHEN** `kubernetes/overlays/prod` is applied
- **THEN** the Deployment has 3 replicas

#### Scenario: Resource limits are configurable
- **WHEN** `kubernetes/base/deployment.yaml` is edited
- **THEN** both environments pick up the new CPU/memory requests and limits

### Requirement: Automated CI/CD Deployment
The system SHALL automatically build, push, and deploy the application on every push to `main`, using the organization's self-hosted ARC runners for any step that requires cluster network access.

#### Scenario: Push to main triggers a full deploy
- **WHEN** a commit is pushed to `main` touching `src/`, `Dockerfile`, or `kubernetes/base|overlays`
- **THEN** a multi-arch image is built and pushed to GHCR, deployed to `biglernet-home-test`, smoke-checked, and then automatically deployed to `biglernet-home-prod`

#### Scenario: Manual redeploy of an existing image
- **WHEN** the deploy workflow is run manually with an `image_tag` input
- **THEN** the build step is skipped and that existing image tag is deployed instead
