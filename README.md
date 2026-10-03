# GitOps Platform on AWS (k3s)

A small end-to-end GitOps setup: a push to GitHub builds a container image, and ArgoCD deploys it to a Kubernetes cluster by itself.

Flow: git push -> GitHub Actions builds image -> image pushed to ghcr.io -> ArgoCD syncs k8s/ manifests -> app runs on k3s (AWS EC2)

## Tech stack
- App: Python Flask (with /health and Prometheus /metrics), Docker (non-root user)
- CI: GitHub Actions (Hadolint, import test, build and push to GitHub Container Registry)
- Cluster: k3s on an AWS EC2 Ubuntu server
- CD: ArgoCD (automated sync, prune and self-heal)

## Why k3s and not EKS
EKS charges for the control plane even when idle. To keep cloud cost near zero, this project runs k3s on a single EC2 instance that is stopped when not in use. The same manifests and ArgoCD setup work on EKS.

## Results
- Git push to live deployment: ~2-3 minutes (ArgoCD auto-sync)
- Rollback with git revert: ~2 minutes
- Self-heal: a deleted Deployment was recreated automatically within seconds

## Status
- [x] Sample app and Dockerfile
- [x] CI pipeline (build and push image)
- [x] Kubernetes manifests
- [x] k3s on EC2 and ArgoCD
- [x] Self-heal, version change via Git, rollback test
- [ ] Prometheus and Grafana monitoring
- [ ] Slack alerts via Alertmanager
- [ ] CI updates the image tag in k8s/ automatically
- [ ] setup.sh to rebuild the server quickly
- [ ] Architecture diagram and screenshots
