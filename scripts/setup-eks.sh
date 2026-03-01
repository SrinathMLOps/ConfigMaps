#!/bin/bash

# AWS EKS Cluster Setup Script for ConfigMap Demo

set -e

echo "🚀 Starting EKS Cluster Setup..."

# Variables
CLUSTER_NAME="configmap-demo"
REGION="us-east-1"
NODE_TYPE="t3.medium"
NODES=2

# Check prerequisites
echo "✅ Checking prerequisites..."
command -v aws >/dev/null 2>&1 || { echo "❌ AWS CLI not installed"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl not installed"; exit 1; }
command -v eksctl >/dev/null 2>&1 || { echo "❌ eksctl not installed"; exit 1; }

echo "✅ All prerequisites met"

# Create EKS cluster
echo "🔨 Creating EKS cluster: $CLUSTER_NAME..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --nodegroup-name standard-workers \
  --node-type $NODE_TYPE \
  --nodes $NODES \
  --nodes-min 1 \
  --nodes-max 3 \
  --managed

echo "✅ EKS cluster created successfully"

# Update kubeconfig
echo "🔧 Updating kubeconfig..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

# Verify cluster
echo "🔍 Verifying cluster..."
kubectl get nodes

# Create namespaces
echo "📦 Creating namespaces..."
kubectl create namespace demo
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace production

echo "✅ Namespaces created"

# Set default namespace
kubectl config set-context --current --namespace=demo

echo "🎉 EKS cluster setup complete!"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Default namespace: demo"
