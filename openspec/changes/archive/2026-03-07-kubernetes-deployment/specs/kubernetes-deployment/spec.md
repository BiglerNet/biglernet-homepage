## ADDED Requirements

### Requirement: Docker Containerization
The system SHALL provide a Dockerfile to containerize the static web application using nginx as the web server.

The image name+tag will be harbor.biglernet.com/library/biglernet-homepage:latest

#### Scenario: Docker build succeeds
- **WHEN** user runs `docker build -t harbor.biglernet.com/library/biglernet-homepage:latest .`
- **THEN** a Docker image is created with the static files served by nginx

#### Scenario: Container starts successfully
- **WHEN** user runs `docker run -p 8080:80 harbor.biglernet.com/library/biglernet-homepage:latest`
- **THEN** the application is accessible at http://localhost:8080

### Requirement: Kubernetes Deployment
The system SHALL provide Kubernetes manifests to deploy the application to a Kubernetes cluster.

#### Scenario: Deployment manifest is valid
- **WHEN** user applies the deployment manifest with `kubectl apply -n biglernet-home-prod -f kubernetes/deployment.yaml`
- **THEN** a Kubernetes Deployment resource is created with the nginx container

#### Scenario: Service exposes the application
- **WHEN** user applies the service manifest with `kubectl apply -n biglernet-home-prod -f kubernetes/service.yaml`
- **THEN** a Kubernetes Service resource is created to expose the deployment internally

### Requirement: External Access via Ingress
The system SHALL provide an Ingress manifest to expose the application externally.

The ingress shall listen on the following hosts:
- biglernet.com
- www.biglernet.com

- TLS will be enabled
- Ingress class is traefik
- Do not specify a TLS secret name. The cluster issues a certificate using a cluster wide issuer systemically.

#### Scenario: Ingress is configured
- **WHEN** user applies the ingress manifest with `kubectl apply -n biglernet-home-prod -f kubernetes/ingress.yaml`
- **THEN** a Kubernetes Ingress resource is created with path-based routing to the service

### Requirement: Multi-stage Docker Build
The Dockerfile SHALL use a multi-stage build to separate the build and runtime environments.

#### Scenario: Build stage completes
- **WHEN** the Dockerfile reaches the build stage
- **THEN** the static files are generated in the build container

#### Scenario: Runtime stage is minimal
- **WHEN** the Dockerfile reaches the runtime stage
- **THEN** only the built static files and nginx are included in the final image

### Requirement: Configuration via Environment Variables
The Kubernetes manifests SHALL allow configuration via environment variables.

#### Scenario: Replicas are configurable
- **WHEN** the deployment is applied with a custom replica count
- **THEN** the number of pod replicas matches the configured value

#### Scenario: Resource limits are configurable
- **WHEN** the deployment is applied with custom resource limits
- **THEN** the container respects the configured CPU and memory limits