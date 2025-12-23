#!/bin/bash

set -e

NAMESPACE=${1:-social-live-backend}
IMAGE_TAG=${2:-latest}
SERVICE_NAME=${3:-backend-api}

echo "Starting zero-downtime deployment for $SERVICE_NAME in $NAMESPACE..."

# Update deployment with new image
kubectl set image deployment/$SERVICE_NAME $SERVICE_NAME=social-live/$SERVICE_NAME:$IMAGE_TAG -n $NAMESPACE

# Wait for rollout to complete
kubectl rollout status deployment/$SERVICE_NAME -n $NAMESPACE --timeout=300s

# Verify deployment health
echo "Verifying deployment health..."
kubectl get pods -n $NAMESPACE -l app=$SERVICE_NAME

# Check if all pods are ready
READY_PODS=$(kubectl get pods -n $NAMESPACE -l app=$SERVICE_NAME -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -o "True" | wc -l)
TOTAL_PODS=$(kubectl get pods -n $NAMESPACE -l app=$SERVICE_NAME --no-headers | wc -l)

if [ "$READY_PODS" -eq "$TOTAL_PODS" ]; then
    echo "✅ Deployment successful! All $TOTAL_PODS pods are ready."
else
    echo "❌ Deployment failed! Only $READY_PODS out of $TOTAL_PODS pods are ready."
    exit 1
fi

echo "Deployment completed successfully!"