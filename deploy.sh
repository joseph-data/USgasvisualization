#!/bin/bash

# deploy.sh - Simple deployment script for US Gas Visualization Shiny App

echo "🚀 US Gas Visualization Deployment Script"
echo "=========================================="

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  local     Run the app locally for development"
    echo "  shiny     Deploy to shinyapps.io (requires configuration)"
    echo "  docker    Build and run Docker container"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 local        # Run locally"
    echo "  $0 shiny        # Deploy to shinyapps.io"
    echo "  $0 docker       # Run with Docker"
}

# Check if R is installed
check_r() {
    if ! command -v R &> /dev/null; then
        echo "❌ R is not installed. Please install R first."
        exit 1
    fi
}

# Local deployment
deploy_local() {
    echo "🏠 Running app locally..."
    check_r
    Rscript local-deploy.R
}

# Deploy to shinyapps.io
deploy_shiny() {
    echo "☁️  Deploying to shinyapps.io..."
    check_r
    
    # Check if deploy.R exists
    if [ ! -f "deploy.R" ]; then
        echo "❌ deploy.R not found. Please ensure you have the deployment script."
        exit 1
    fi
    
    echo "📝 Make sure you have configured your shinyapps.io credentials first:"
    echo "   rsconnect::setAccountInfo(name='your-account', token='your-token', secret='your-secret')"
    echo ""
    read -p "Press Enter to continue with deployment..."
    
    Rscript deploy.R
}

# Docker deployment
deploy_docker() {
    echo "🐳 Building and running Docker container..."
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        echo "❌ Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    # Check if Dockerfile exists
    if [ ! -f "Dockerfile" ]; then
        echo "❌ Dockerfile not found."
        exit 1
    fi
    
    echo "🔨 Building Docker image..."
    docker build -t usgasvisualization .
    
    echo "🚀 Running Docker container..."
    echo "App will be available at: http://localhost:3838"
    docker run -p 3838:3838 usgasvisualization
}

# Main script logic
case "$1" in
    local)
        deploy_local
        ;;
    shiny)
        deploy_shiny
        ;;
    docker)
        deploy_docker
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Invalid option: $1"
        echo ""
        show_help
        exit 1
        ;;
esac