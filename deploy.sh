#!/bin/bash

# Universal deployment script for US Gas Visualization Shiny App

set -e

echo "🚀 US Gas Visualization Deployment Script"
echo "=========================================="
echo ""
echo "Choose your deployment method:"
echo "1) Docker (local container)"
echo "2) shinyapps.io (cloud hosting)"
echo "3) Local development"
echo "4) Exit"
echo ""

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🐳 Docker Deployment"
        echo "==================="
        
        # Check if Docker is installed
        if ! command -v docker &> /dev/null; then
            echo "❌ Docker is not installed. Please install Docker first."
            echo "Visit: https://docs.docker.com/get-docker/"
            exit 1
        fi
        
        # Check if Docker Compose is available
        if ! docker compose version &> /dev/null; then
            echo "❌ Docker Compose is not available. Please install Docker Compose first."
            exit 1
        fi
        
        echo "🔨 Building Docker image..."
        docker compose build
        
        echo "🚀 Starting the application..."
        docker compose up -d
        
        echo "⏳ Waiting for application to start..."
        sleep 5
        
        # Check if the container is running
        if docker compose ps | grep -q "Up"; then
            echo "✅ Application is running!"
            echo "🌐 Access your app at: http://localhost:3838"
            echo ""
            echo "📋 Useful commands:"
            echo "  - View logs: docker compose logs -f"
            echo "  - Stop app: docker compose down"
            echo "  - Restart app: docker compose restart"
        else
            echo "❌ Application failed to start. Check logs with: docker compose logs"
            exit 1
        fi
        ;;
        
    2)
        echo ""
        echo "☁️ shinyapps.io Deployment"
        echo "========================="
        echo ""
        echo "To deploy to shinyapps.io, you need to:"
        echo "1. Have R installed"
        echo "2. Create a shinyapps.io account"
        echo "3. Configure your deployment credentials"
        echo ""
        echo "Follow the instructions in: rsconnect/shinyapps.io/deploy.R"
        echo "Or refer to: DEPLOYMENT.md"
        echo ""
        echo "Quick setup:"
        echo "1. Open R or RStudio"
        echo "2. Run: source('rsconnect/shinyapps.io/deploy.R')"
        echo "3. Follow the instructions in the script"
        ;;
        
    3)
        echo ""
        echo "💻 Local Development"
        echo "==================="
        echo ""
        if ! command -v R &> /dev/null; then
            echo "❌ R is not installed. Please install R first."
            echo "Visit: https://www.r-project.org/"
            exit 1
        fi
        
        echo "📦 Installing required packages..."
        echo "This may take a few minutes..."
        
        R -e "
        packages <- c('shiny', 'dplyr', 'ggplot2', 'readr', 'tidyr', 'lubridate', 'scales', 'viridis', 'patchwork', 'plotly')
        new_packages <- packages[!(packages %in% installed.packages()[,'Package'])]
        if(length(new_packages)) {
            install.packages(new_packages, repos='https://cran.rstudio.com/')
        }
        cat('✅ All packages installed successfully!\n')
        "
        
        echo "🚀 Starting the Shiny app..."
        echo "The app will open in your default browser"
        echo "Press Ctrl+C to stop the app"
        
        R -e "shiny::runApp('app.R')"
        ;;
        
    4)
        echo "👋 Goodbye!"
        exit 0
        ;;
        
    *)
        echo "❌ Invalid choice. Please run the script again and choose 1-4."
        exit 1
        ;;
esac