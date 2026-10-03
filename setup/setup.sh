#!/usr/bin/env bash
# Rebuilds the whole platform on a fresh Ubuntu server: k3s + Helm + ArgoCD + the app.
# Safe to run more than once. It only installs software inside this server,
# it does not create anything in AWS.
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/adityachaurasiya0112-code/gitops-platform/main"
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

echo ">>> [1/5] Updating packages"
sudo apt-get update -y

echo ">>> [2/5] Installing k3s"
if ! command -v k3s >/dev/null 2>&1; then
  curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable traefik
else
  echo "k3s already installed, skipping"
fi
grep -q "KUBECONFIG" ~/.bashrc || echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
kubectl wait --for=condition=Ready node --all --timeout=180s

echo ">>> [3/5] Installing Helm"
if ! command -v helm >/dev/null 2>&1; then
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
  echo "helm already installed, skipping"
fi

echo ">>> [4/5] Installing ArgoCD"
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s

echo ">>> [5/5] Deploying the app through ArgoCD"
kubectl apply -f "$REPO_RAW/argocd/application.yaml"

echo ""
echo "Done. Check progress with:"
echo "  kubectl get applications -n argocd"
echo "  kubectl get pods"
echo "App URL: http://<PUBLIC-IP>:30080/"
