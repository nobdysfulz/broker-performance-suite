#!/bin/bash

# Complete Deployment Automation Script
# Usage: ./deploy.sh PROJECT_ID [REGION]

set -e

PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"us-central1"}
SERVICE_NAME="my-app"

echo "🚀 Starting complete deployment to Google Cloud..."
echo "📝 Project: $PROJECT_ID"
echo "📝 Region: $REGION"
echo "📝 Service: $SERVICE_NAME"

# Check if gcloud is installed and authenticated
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install it first."
    exit 1
fi

# Set the project
echo "🔧 Setting up gcloud configuration..."
gcloud config set project $PROJECT_ID
gcloud config set run/region $REGION

# Enable required APIs
echo "📡 Enabling required Google Cloud APIs..."
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com

# Run setup scripts
echo "🗄️  Setting up Cloud SQL..."
if [ -f "./scripts/setup-cloud-sql.sh" ]; then
    ./scripts/setup-cloud-sql.sh $PROJECT_ID $REGION
else
    echo "⚠️  Cloud SQL setup script not found. Skipping..."
fi

echo "🔐 Setting up IAM roles..."
if [ -f "./scripts/setup-iam.sh" ]; then
    ./scripts/setup-iam.sh $PROJECT_ID
else
    echo "⚠️  IAM setup script not found. Skipping..."
fi

# Build and deploy using Cloud Build
echo "🏗️  Building and deploying with Cloud Build..."
gcloud builds submit --config cloudbuild.yaml --substitutions=_REGION=$REGION,_SERVICE_NAME=$SERVICE_NAME

# Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
sleep 30

# Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

echo "✅ Deployment complete!"
echo "🌐 Service URL: $SERVICE_URL"
echo "📊 Health check: $SERVICE_URL/api/health"

# Test the deployment
echo "🧪 Testing deployment..."
if curl -f -s "$SERVICE_URL/api/health" > /dev/null; then
    echo "✅ Health check passed!"
else
    echo "❌ Health check failed. Please check the logs."
    gcloud run services logs read $SERVICE_NAME --region=$REGION --limit=50
fi

echo "🎉 Deployment process completed!"
echo ""
echo "📋 Next steps:"
echo "   1. Configure custom domain (if needed)"
echo "   2. Set up monitoring and alerting"
echo "   3. Configure SSL certificates"
echo "   4. Set up CI/CD pipeline"
