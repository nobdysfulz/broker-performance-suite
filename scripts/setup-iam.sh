#!/bin/bash

# IAM Roles and Permissions Setup Script
# Usage: ./setup-iam.sh PROJECT_ID

set -e

PROJECT_ID=${1:-"your-project-id"}
SERVICE_ACCOUNT_NAME="my-app-service-account"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"

echo "🔐 Setting up IAM roles and permissions..."

# Create service account for the application
echo "👤 Creating service account: $SERVICE_ACCOUNT_NAME"
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
    --display-name="My App Service Account" \
    --description="Service account for my application" \
    --project=$PROJECT_ID

# Grant necessary roles to the service account
echo "🎭 Granting roles to service account..."

# Cloud SQL Client role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/cloudsql.client"

# Secret Manager Secret Accessor role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/secretmanager.secretAccessor"

# Cloud Trace Agent role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/cloudtrace.agent"

# Cloud Monitoring Metric Writer role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/monitoring.metricWriter"

# Cloud Logging Writer role
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
    --role="roles/logging.logWriter"

# Grant Cloud Build access to deploy to Cloud Run
echo "🏗️  Granting Cloud Build permissions..."
CLOUD_BUILD_SA="$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')@cloudbuild.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/run.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$CLOUD_BUILD_SA" \
    --role="roles/iam.serviceAccountUser"

# Create and download service account key (for local development)
echo "🔑 Creating service account key..."
gcloud iam service-accounts keys create ./service-account-key.json \
    --iam-account=$SERVICE_ACCOUNT_EMAIL \
    --project=$PROJECT_ID

echo "✅ IAM setup complete!"
echo "📝 Service Account: $SERVICE_ACCOUNT_EMAIL"
echo "📝 Key file: ./service-account-key.json"
echo "⚠️  Keep the key file secure and never commit it to version control!"
