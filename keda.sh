#!/bin/bash

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

check_helm
check_keda
