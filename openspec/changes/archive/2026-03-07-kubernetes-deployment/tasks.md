## 1. Docker Configuration

- [x] 1.1 Create Dockerfile with multi-stage build
- [x] 1.2 Create .dockerignore file to exclude unnecessary files
- [x] 1.3 Test Docker build locally, use the tag `harbor.biglernet.com/library/biglernet-homepage:latest` (Credentials are configured for this registry by the host, do not verify. Just go ahead and push. If it fails, ask user for creds.)
- [x] 1.4 Test running the docker image to verify it starts correctly. Also test via a curl command to ensure it gets the expected results.

## 2. Kubernetes Manifests

- [x] 2.1 Create kubernetes/deployment.yaml with nginx container
- [x] 2.2 Create kubernetes/service.yaml for internal load balancing
- [x] 2.3 Create kubernetes/ingress.yaml for external access
- [x] 2.4 Create kubernetes/configmap.yaml for nginx configuration (optional)
- [x] 2.5 Create kubernetes/namespace.yaml for resource isolation

## 3. Documentation

- [x] 3.1 Create DEPLOYMENT.md with step-by-step instructions
- [x] 3.2 Document environment-specific configuration
- [x] 3.3 Add troubleshooting section for common issues

## 4. Initial deploy

- [x] 4.1 Build and push the docker image using the tag `harbor.biglernet.com/library/biglernet-homepage:latest` (Credentials are configured for this registry by the host, do not verify. Just go ahead and push. If it fails, ask user for creds.)
- [x] 4.2 Use `kubectl` to apply the changes to the desired namespace `biglernet-home-prod` - Requires 4.1 to be complete before attempting this
- [x] 4.3 Verify success via curl commands against hosts: `www.biglernet.com` and `biglernet.com`
