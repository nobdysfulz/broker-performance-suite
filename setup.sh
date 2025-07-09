#!/bin/bash

# Complete Setup Script for Google Cloud Deployment
# This script sets up everything needed for deployment

set -e

echo "🚀 Google Cloud Deployment Package Setup"
echo "========================================"

# Check if required tools are installed
check_requirements() {
    echo "🔍 Checking requirements..."

    if ! command -v gcloud &> /dev/null; then
        echo "❌ Google Cloud SDK is not installed"
        echo "   Please install it from: https://cloud.google.com/sdk/docs/install"
        exit 1
    fi

    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed"
        echo "   Please install it from: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! command -v node &> /dev/null; then
        echo "❌ Node.js is not installed"
        echo "   Please install it from: https://nodejs.org/"
        exit 1
    fi

    echo "✅ All requirements satisfied"
}

# Get project configuration
get_project_config() {
    echo ""
    echo "📋 Project Configuration"
    echo "========================"

    if [ -z "$1" ]; then
        read -p "Enter your Google Cloud Project ID: " PROJECT_ID
    else
        PROJECT_ID=$1
    fi

    if [ -z "$2" ]; then
        read -p "Enter your preferred region (default: us-central1): " REGION
        REGION=${REGION:-us-central1}
    else
        REGION=$2
    fi

    if [ -z "$3" ]; then
        read -p "Enter your service name (default: my-app): " SERVICE_NAME
        SERVICE_NAME=${SERVICE_NAME:-my-app}
    else
        SERVICE_NAME=$3
    fi

    echo "📝 Configuration:"
    echo "   Project ID: $PROJECT_ID"
    echo "   Region: $REGION"
    echo "   Service Name: $SERVICE_NAME"
    echo ""
}

# Update configuration files
update_config_files() {
    echo "🔧 Updating configuration files..."

    # Update cloudbuild.yaml
    if [ -f "cloudbuild.yaml" ]; then
        sed -i.bak "s/\$PROJECT_ID/$PROJECT_ID/g" cloudbuild.yaml
        sed -i.bak "s/_REGION: 'us-central1'/_REGION: '$REGION'/g" cloudbuild.yaml
        sed -i.bak "s/_SERVICE_NAME: 'my-app'/_SERVICE_NAME: '$SERVICE_NAME'/g" cloudbuild.yaml
        echo "   ✅ Updated cloudbuild.yaml"
    fi

    # Update environment files
    if [ -f "config/.env.production" ]; then
        sed -i.bak "s/PROJECT_ID/$PROJECT_ID/g" config/.env.production
        sed -i.bak "s/REGION/$REGION/g" config/.env.production
        echo "   ✅ Updated config/.env.production"
    fi

    # Update scripts
    for script in scripts/*.sh; do
        if [ -f "$script" ]; then
            sed -i.bak "s/your-project-id/$PROJECT_ID/g" "$script"
            sed -i.bak "s/us-central1/$REGION/g" "$script"
            echo "   ✅ Updated $script"
        fi
    done

    # Clean up backup files
    find . -name "*.bak" -delete

    echo "✅ Configuration files updated"
}

# Set up Google Cloud
setup_gcloud() {
    echo ""
    echo "☁️  Setting up Google Cloud..."

    # Set project
    gcloud config set project $PROJECT_ID
    gcloud config set run/region $REGION

    # Enable APIs
    echo "📡 Enabling required APIs..."
    gcloud services enable cloudbuild.googleapis.com
    gcloud services enable run.googleapis.com
    gcloud services enable containerregistry.googleapis.com
    gcloud services enable sqladmin.googleapis.com
    gcloud services enable secretmanager.googleapis.com

    echo "✅ Google Cloud setup complete"
}

# Install dependencies
install_dependencies() {
    echo ""
    echo "📦 Installing dependencies..."

    # Install root dependencies
    if [ -f "package.json" ]; then
        npm install
        echo "   ✅ Root dependencies installed"
    fi

    # Install server dependencies
    if [ -f "server/package.json" ]; then
        cd server
        npm install
        cd ..
        echo "   ✅ Server dependencies installed"
    fi

    # Install client dependencies
    if [ -f "client/package.json" ]; then
        cd client
        npm install
        cd ..
        echo "   ✅ Client dependencies installed"
    fi

    echo "✅ All dependencies installed"
}

# Make scripts executable
make_scripts_executable() {
    echo ""
    echo "🔧 Making scripts executable..."

    chmod +x scripts/*.sh

    echo "✅ Scripts are now executable"
}

# Main setup function
main() {
    echo "Starting setup process..."
    echo ""

    check_requirements
    get_project_config "$@"
    update_config_files
    setup_gcloud
    install_dependencies
    make_scripts_executable

    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    echo ""
    echo "Next steps:"
    echo "1. Review the updated configuration files"
    echo "2. Test locally: docker-compose up -d"
    echo "3. Deploy to Google Cloud: ./scripts/deploy.sh $PROJECT_ID $REGION"
    echo ""
    echo "For more information, see README.md and docs/"
}

# Run main function with all arguments
main "$@"
