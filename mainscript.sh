#!/bin/bash

#Login to the kubernetes clsuter


aws eks update-kubeconfig --name Certificate --region ap-south-1

helm_version="v3.16.1"


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


#check keda

check_keda() {
  if helm repo list 2>&1 | grep -q "kedacore"
  then
    echo "keda is already installed "
  else
    echo "keda is not installed or the version is incorrect, installing Helm..."
    install_keda
  fi
}



# Function to install KEDA
install_keda() {
  echo "Installing KEDA..."
  # Add KEDA Helm repo and update Helm repos
  helm repo add kedacore https://kedacore.github.io/charts
  helm repo update

  # Install KEDA into the keda namespace
  kubectl create namespace keda
  helm install keda kedacore/keda --namespace keda

  if helm repo list 2>&1 | grep -q "kedacore"
    echo "KEDA installed successfully in the 'keda' namespace."
  else
    echo "Failed to install KEDA." >&2
    exit 1
  fi
}

main() {
  check_helm
  check_keda
}

# Run the main function
main



#Create secrets and login to dockerhub

dockerhub_user_name=<username>
password_dockerhub=<password>
email=<enail>
kubectl create secret docker-registry dockerhub-secret \
  --docker-username=$dockerhub_user_name \
  --docker-password=$password_dockerhub \
  --docker-email=$email
kubectl patch serviceaccount default \
  -p '{"imagePullSecrets": [{"name": "dockerhub-secret"}]}'



#Deploy Application in the Kubernetes cluster

cd ./Deployment

ls
namespace=sampleapplication

check_namespace() {
  if kubectl get ns 2>&1 | grep -q $namespace
  then
    echo "namespae '$namespace' is already create" 
  else
    echo "namespae '$namespace' is not present need to create."
    kubectl create ns $namespace
  fi
}


