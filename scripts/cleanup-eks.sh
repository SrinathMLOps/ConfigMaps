#!/bin/bash

# Cleanup script for EKS cluster

set -e

CLUSTER_NAME="configmap-demo"
REGION="us-east-1"

echo "🧹 Cleaning up EKS cluster: $CLUSTER_NAME..."

# Delete cluster
eksctl delete cluster --name $CLUSTER_NAME --region $REGION

echo "✅ Cleanup complete!"
