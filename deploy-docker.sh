#!/bin/bash

# Docker deployment script for US Gas Visualization Shiny App

set -e

echo "🚀 Starting deployment of US Gas Visualization Shiny App..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose first."
    exit 1
fi

# Build and run the container
echo "🔨 Building Docker image..."
docker compose build

echo "🚀 Starting the application..."
docker compose up -d

# Wait for the app to start
echo "⏳ Waiting for application to start..."
sleep 10

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