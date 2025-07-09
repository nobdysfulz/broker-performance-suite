#!/bin/bash

# Cloud SQL PostgreSQL Setup Script
# Usage: ./setup-cloud-sql.sh PROJECT_ID REGION

set -e

PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"us-central1"}
INSTANCE_NAME="my-db-instance"
DATABASE_NAME="myapp_db"
DB_USER="app_user"

echo "🗄️  Setting up Cloud SQL PostgreSQL instance..."

# Enable required APIs
echo "📡 Enabling required APIs..."
gcloud services enable sqladmin.googleapis.com --project=$PROJECT_ID
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID

# Create Cloud SQL instance
echo "🏗️  Creating Cloud SQL instance: $INSTANCE_NAME"
gcloud sql instances create $INSTANCE_NAME \
    --database-version=POSTGRES_14 \
    --tier=db-f1-micro \
    --region=$REGION \
    --storage-type=SSD \
    --storage-size=10GB \
    --storage-auto-increase \
    --backup-start-time=03:00 \
    --enable-bin-log \
    --maintenance-window-day=SUN \
    --maintenance-window-hour=04 \
    --project=$PROJECT_ID

# Set root password
echo "🔐 Setting root password..."
ROOT_PASSWORD=$(openssl rand -base64 32)
gcloud sql users set-password postgres \
    --instance=$INSTANCE_NAME \
    --password=$ROOT_PASSWORD \
    --project=$PROJECT_ID

# Create application database
echo "📊 Creating database: $DATABASE_NAME"
gcloud sql databases create $DATABASE_NAME \
    --instance=$INSTANCE_NAME \
    --project=$PROJECT_ID

# Create application user
echo "👤 Creating database user: $DB_USER"
DB_PASSWORD=$(openssl rand -base64 32)
gcloud sql users create $DB_USER \
    --instance=$INSTANCE_NAME \
    --password=$DB_PASSWORD \
    --project=$PROJECT_ID

# Store credentials in Secret Manager
echo "🔒 Storing credentials in Secret Manager..."

# Create database credentials secret
cat <<EOF | gcloud secrets create db-credentials --data-file=- --project=$PROJECT_ID
{
  "host": "/cloudsql/$PROJECT_ID:$REGION:$INSTANCE_NAME",
  "username": "$DB_USER",
  "password": "$DB_PASSWORD",
  "database": "$DATABASE_NAME",
  "port": "5432"
}
EOF

# Create app secrets
JWT_SECRET=$(openssl rand -base64 64)
cat <<EOF | gcloud secrets create app-secrets --data-file=- --project=$PROJECT_ID
{
  "jwt-secret": "$JWT_SECRET",
  "session-secret": "$(openssl rand -base64 32)"
}
EOF

echo "✅ Cloud SQL setup complete!"
echo "📝 Instance: $INSTANCE_NAME"
echo "📝 Database: $DATABASE_NAME"
echo "📝 User: $DB_USER"
echo "📝 Connection: $PROJECT_ID:$REGION:$INSTANCE_NAME"

# Grant Cloud Run access to secrets
echo "🔑 Granting Cloud Run access to secrets..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_ID@appspot.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"

echo "🎉 Setup complete! Your Cloud SQL instance is ready."
