## Context

The BiglerNet homepage is a static web application that needs to be deployed to a Kubernetes cluster. Currently, there is no standardized deployment mechanism, making it difficult to deploy to production or staging environments. The application generates static HTML/CSS/JS files that need to be served via a web server.

## Goals / Non-Goals

**Goals:**
- Create a Dockerfile to containerize the static web application using nginx as the web server
- Create Kubernetes manifests (Deployment, Service, Ingress) for deploying the application
- Provide clear documentation for the deployment process

**Non-Goals:**
- Modifying the application code or build process
- Managing database or backend services (this is a static site)
- Implementing advanced Kubernetes features (e.g., Helm charts, StatefulSets)
- Creating CI/CD integration for automated deployments

## Decisions

**1. Docker Image Base: nginx**
- *Decision*: Use nginx as the base image for serving static content
- *Rationale*: nginx is lightweight, widely used, and excellent for serving static files. The official nginx image is well-maintained and secure.

**2. Multi-stage Docker Build**
- *Decision*: Use a multi-stage build to separate build and runtime environments. Expect image tag to be
- *Rationale*: This keeps the final image small and secure by only including the built artifacts, not the build tools.

**3. Kubernetes Manifests Structure**
- *Decision*: Create separate YAML files for Deployment, Service, and Ingress
- *Rationale*: This provides clarity and allows for independent management of each resource. Users can apply only the resources they need.

**4. Ingress Configuration**
- *Decision*: Use Kubernetes Ingress for external access with path-based routing. MUST use traefik ingress class. MUST configure TLS to allow secure connections. MUST not specify a TLS secret name, the destination Kubernetes environment will automatically handle certificate management at the cluster level with a wildcard certificate. MUST support both `biglernet.com` and `www.biglernet.com` hosts.
- *Rationale*: Ingress provides a clean way to expose the application externally and allows for SSL termination and custom domains.

**5. Configuration via Environment Variables**
- *Decision*: Use environment variables for configurable values (replicas, resource limits)
- *Rationale*: This allows for easy customization without modifying the manifest files.

## Risks / Trade-offs

- **Risk**: Hardcoded image tag in Kubernetes manifests
  - *Mitigation*: Document that users should update the image tag for each deployment

- **Risk**: No persistent storage configuration
  - *Mitigation*: Since this is a static site, no persistent storage is needed. All content is served from the container image.

- **Risk**: No health check configuration
  - *Mitigation*: Add basic HTTP health checks using nginx's default health endpoint

## Migration Plan

1. Build the Docker image: `docker build -t harbor.biglernet.com/library/biglernet-homepage:latest .`
2. Push the image to a container registry: `docker push harbor.biglernet.com/library/biglernet-homepage:latest`
3. Update the image tag in `kubernetes/deployment.yaml`
4. Apply Kubernetes manifests: `kubectl apply -n biglernet-home-prod -f kubernetes/`
5. Verify deployment: `kubectl -n biglernet-home-prod get pods,svc,ingress`

**Rollback Strategy:**
- To rollback, update the image tag in `deployment.yaml` to the previous version and re-apply
- Consider using GitOps (e.g., ArgoCD) for automatic rollback capabilities