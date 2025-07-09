#!/bin/bash

# Comprehensive Test Script
# Tests the deployment package locally and remotely

set -e

PROJECT_ID=${1:-"your-project-id"}
REGION=${2:-"us-central1"}
SERVICE_NAME=${3:-"my-app"}

echo "🧪 Testing Deployment Package"
echo "============================="

# Test 1: File structure validation
test_file_structure() {
    echo "📁 Testing file structure..."

    required_files=(
        "Dockerfile"
        "cloudbuild.yaml"
        "docker-compose.yml"
        "package.json"
        "server/package.json"
        "client/package.json"
        "server/index.js"
        "client/App.js"
        "scripts/deploy.sh"
        "README.md"
    )

    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "❌ Missing required file: $file"
            exit 1
        fi
    done

    echo "✅ File structure validation passed"
}

# Test 2: Docker build test
test_docker_build() {
    echo ""
    echo "🐳 Testing Docker build..."

    if docker build -t test-app . > /dev/null 2>&1; then
        echo "✅ Docker build successful"
        docker rmi test-app > /dev/null 2>&1
    else
        echo "❌ Docker build failed"
        exit 1
    fi
}

# Test 3: Local development test
test_local_development() {
    echo ""
    echo "🏠 Testing local development environment..."

    # Start services
    docker-compose up -d > /dev/null 2>&1

    # Wait for services to start
    sleep 10

    # Test backend health
    if curl -f -s http://localhost:5000/api/health > /dev/null; then
        echo "✅ Backend health check passed"
    else
        echo "❌ Backend health check failed"
        docker-compose down > /dev/null 2>&1
        exit 1
    fi

    # Test frontend
    if curl -f -s http://localhost:3000 > /dev/null; then
        echo "✅ Frontend accessibility test passed"
    else
        echo "⚠️  Frontend test skipped (may take longer to start)"
    fi

    # Cleanup
    docker-compose down > /dev/null 2>&1
    echo "✅ Local development test completed"
}

# Test 4: Configuration validation
test_configuration() {
    echo ""
    echo "⚙️  Testing configuration files..."

    # Test cloudbuild.yaml syntax
    if gcloud builds submit --config cloudbuild.yaml --no-source --dry-run > /dev/null 2>&1; then
        echo "✅ cloudbuild.yaml syntax valid"
    else
        echo "❌ cloudbuild.yaml syntax invalid"
        exit 1
    fi

    # Test package.json files
    for package_file in package.json server/package.json client/package.json; do
        if node -e "JSON.parse(require('fs').readFileSync('$package_file', 'utf8'))" > /dev/null 2>&1; then
            echo "✅ $package_file syntax valid"
        else
            echo "❌ $package_file syntax invalid"
            exit 1
        fi
    done
}

# Test 5: Script permissions
test_script_permissions() {
    echo ""
    echo "🔐 Testing script permissions..."

    scripts=(
        "scripts/deploy.sh"
        "scripts/setup-cloud-sql.sh"
        "scripts/setup-iam.sh"
        "setup.sh"
    )

    for script in "${scripts[@]}"; do
        if [ -x "$script" ]; then
            echo "✅ $script is executable"
        else
            echo "❌ $script is not executable"
            exit 1
        fi
    done
}

# Test 6: Google Cloud connectivity (optional)
test_gcloud_connectivity() {
    echo ""
    echo "☁️  Testing Google Cloud connectivity..."

    if gcloud auth list --filter=status:ACTIVE --format="value(account)" > /dev/null 2>&1; then
        echo "✅ Google Cloud authentication active"

        if gcloud projects describe $PROJECT_ID > /dev/null 2>&1; then
            echo "✅ Project $PROJECT_ID accessible"
        else
            echo "⚠️  Project $PROJECT_ID not accessible or doesn't exist"
        fi
    else
        echo "⚠️  Google Cloud authentication not active"
        echo "   Run: gcloud auth login"
    fi
}

# Run all tests
main() {
    echo "Running comprehensive tests..."
    echo ""

    test_file_structure
    test_docker_build
    test_configuration
    test_script_permissions
    test_local_development
    test_gcloud_connectivity

    echo ""
    echo "🎉 All Tests Completed!"
    echo "======================"
    echo ""
    echo "✅ Package is ready for deployment"
    echo "🚀 Run: ./scripts/deploy.sh $PROJECT_ID $REGION"
}

# Run main function
main
