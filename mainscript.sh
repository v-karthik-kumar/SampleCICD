#!/bin/bash

# Source the variables from the external file
source ./variables.sh

check_helm() {
  if helm version 2>&1 | grep -q $helm_version
  then
    echo "Helm is already installed and the version is correct. '$version'"
  else
    echo "Helm is not installed or the version is incorrect, installing Helm..."
    install_helm
  fi
}

install_helm() {
  # Download and install Helm
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  if [ $? -eq 0 ]; then
    echo "Helm installation completed successfully."
  else
    echo "Failed to install Helm." >&2
    exit 1
  fi
}

check_keda() {
  if helm repo list 2>&1 | grep -q "kedacore"
  then
    echo "KEDA is already installed."
  else
    echo "KEDA is not installed or the version is incorrect, installing KEDA..."
    install_keda
  fi
}

install_keda() {
  echo "Installing KEDA..."
  helm repo add kedacore https://kedacore.github.io/charts
  helm repo update

  kubectl create namespace keda
  helm install keda kedacore/keda --namespace keda

  if helm repo list 2>&1 | grep -q "kedacore"
  then
    echo "KEDA installed successfully in the 'keda' namespace."
  else
    echo "Failed to install KEDA." >&2
    exit 1
  fi
}

check_namespace() {
  if kubectl get ns 2>&1 | grep -q $namespace
  then
    echo "Namespace '$namespace' is already created."
  else
    echo "Namespace '$namespace' is not present, creating it."
    kubectl create ns $namespace
  fi
}

main() {
  check_helm
  check_keda
  check_namespace

  # Create DockerHub secret
  kubectl create secret docker-registry dockerhub-secret \
    --docker-username=$dockerhub_user_name \
    --docker-password=$password_dockerhub \
    --docker-email=$email
  kubectl patch serviceaccount default \
    -p '{"imagePullSecrets": [{"name": "dockerhub-secret"}]}'

  # Deploy application
  kubectl apply -f Pythonapplication.yaml -n $namespace
  echo "Checking deployment status..."
  sleep 10  # Wait for some time for the deployment to proceed
  DEPLOY_STATUS=$(kubectl rollout status deployment/pythonapplication --timeout=60s || echo "FAILED")
  echo "deployment status"

  if [[ "$DEPLOY_STATUS" == "FAILED" ]]; then
      echo "Deployment failed, rolling back...";
      kubectl rollout undo deployment/pythonapplication;
  else
      echo "Deployment succeeded!";
      get_deployment_details
      get_service_details
      get_scaling_configuration
      check_deployment_status

  fi

  # Install metrics server
  helm install metrics-server stable/metrics-server

  # Autoscale the deployment
  kubectl autoscale deployment pythonapplication --cpu-percent=75 --min=50 --max=100 -n $namespace
}

get_deployment_details() {
  echo "Deployment Details:"
  kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE
}

get_service_details() {
  echo "Service Details:"
  kubectl get service $SERVICE_NAME -n $NAMESPACE
}

get_scaling_configuration() {
  echo "Scaling Configuration:"
  kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.replicas}'
}

check_deployment_status() {
  echo "Checking deployment status..."
  kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE

  echo "Retrieving pod status..."
  kubectl get pods -l app=$DEPLOYMENT_NAME -n $NAMESPACE

  echo "Getting detailed pod information..."
  kubectl describe pods -l app=$DEPLOYMENT_NAME -n $NAMESPACE

  echo "Fetching CPU and memory usage..."
  kubectl top pod -l app=$DEPLOYMENT_NAME -n $NAMESPACE

  echo "Checking for events or failures..."
  kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp

  get_deployment_details
  get_service_details
  echo "Scaling Configuration (Replicas):"
  get_scaling_configuration
}

# Run the main function
main
