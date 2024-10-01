# Install using kubectl
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Or use Helm (if available)
helm install metrics-server stable/metrics-server
