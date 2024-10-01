DEPLOYMENT_NAME=send-intv-msg-live
NAMESPACE=default
SERVICE_NAME=send-intv-msg-live


# Function to get deployment details
get_deployment_details() {
  echo "Deployment Details:"
  kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE |grep $DEPLOYMENT_NAME
}

# Function to get service details
get_service_details() {
  echo "Service Details:"
  kubectl get service $SERVICE_NAME -n $NAMESPACE |grep  $SERVICE_NAME
}

# Function to get scaling configuration
get_scaling_configuration() {
  echo "Scaling Configuration:"
  kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o=jsonpath='{.spec.replicas}'
  echo " ============ "
}




# Check deployment status
echo "Checking deployment status..."
kubectl get deployment $DEPLOYMENT_ID -n $NAMESPACE

# Check pod statuses
echo "Retrieving pod status..."
kubectl get pods -l app=$DEPLOYMENT_ID -n $NAMESPACE

# Get detailed pod description
echo "Getting detailed pod information..."
kubectl describe pods -l app=$DEPLOYMENT_ID -n $NAMESPACE

# Fetch CPU and memory usage of pods
echo "Fetching CPU and memory usage..."
kubectl top pod -l app=$DEPLOYMENT_ID -n $NAMESPACE

# Retrieve any relevant events
echo "Checking for events or failures..."
kubectl get events -n $NAMESPACE --sort-by=.metadata.creationTimestamp

sleep 5

# Return details
get_deployment_details
get_service_details
echo "Scaling Configuration (Replicas):"
get_scaling_configuration
