kubectl create secret docker-registry dockerhub-secret \
  --docker-username=<your-dockerhub-username> \
  --docker-password=<your-dockerhub-password> \
  --docker-email=<your-email>
kubectl patch serviceaccount default \
  -p '{"imagePullSecrets": [{"name": "dockerhub-secret"}]}'
