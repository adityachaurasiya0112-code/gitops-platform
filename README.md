# GitOps Platform on AWS (k3s)

A small end-to-end GitOps setup: a push to GitHub builds a container image, and ArgoCD deploys it to a Kubernetes cluster by itself.

Flow: git push -> GitHub Actions builds image -> image pushed to ghcr.io -> ArgoCD syncs k8s/ manifests -> app runs on k3s (AWS EC2)

## Tech stack
- App: Python Flask (with /health and Prometheus /metrics), Docker (non-root user)
- CI: GitHub Actions (Hadolint, import test, build and push to GitHub Container Registry)
- Cluster: k3s on an AWS EC2 Ubuntu server
- CD: ArgoCD (automated sync, prune and self-heal)
- Monitoring: Prometheus and Grafana (kube-prometheus-stack, installed through ArgoCD)

## Why k3s and not EKS
EKS charges for the control plane even when idle. To keep cloud cost near zero, this project runs k3s on a single EC2 instance that is stopped when not in use. The same manifests and ArgoCD setup work on EKS.

## Results
- Git push to live deployment: ~2-3 minutes (ArgoCD auto-sync)
- Rollback with git revert: ~2 minutes
- Self-heal: a deleted Deployment was recreated automatically within seconds
- Stop and start of the server: k3s, ArgoCD and the app came back on their own

## Screenshots
![ArgoCD apps synced and healthy](docs/argocd-synced.png)
![App running via ArgoCD](docs/app-live.png)
![App requests in Grafana](docs/grafana-requests.png)
![Request rate in Grafana](docs/grafana-rate.png)
![Monitoring pods running](docs/monitoring-pods.png)

## Monitoring
A ServiceMonitor makes Prometheus scrape the app's /metrics endpoint, and Grafana shows the request counter and request rate per pod.

## Rebuild the platform
On a fresh Ubuntu server, download and run the setup script:

    curl -fsSLO https://raw.githubusercontent.com/adityachaurasiya0112-code/gitops-platform/main/setup/setup.sh
    bash setup.sh

## Status
- [x] Sample app and Dockerfile
- [x] CI pipeline (build and push image)
- [x] Kubernetes manifests
- [x] k3s on EC2 and ArgoCD
- [x] Self-heal, version change via Git, rollback test
- [x] setup.sh to rebuild the server quickly
- [x] Prometheus and Grafana monitoring
- [ ] Slack alerts via Alertmanager
- [ ] CI updates the image tag in k8s/ automatically
- [ ] Architecture diagram