#!/bin/bash

# Environment setup script for US Gas Visualization

echo "🔧 Setting up development environment..."
echo ""

# Check if R is installed
if ! command -v R &> /dev/null; then
    echo "❌ R is not installed."
    echo "Please install R from: https://www.r-project.org/"
    exit 1
fi

echo "✅ R is installed: $(R --version | head -1)"

# Install required packages
echo "📦 Installing required R packages..."
echo "This may take several minutes..."

R -e "
# List of required packages
packages <- c(
    'shiny',
    'dplyr',
    'ggplot2', 
    'readr',
    'tidyr',
    'lubridate',
    'scales',
    'viridis',
    'patchwork',
    'plotly',
    'rsconnect'
)

# Check which packages need to be installed
new_packages <- packages[!(packages %in% installed.packages()[,'Package'])]

if(length(new_packages) > 0) {
    cat('Installing packages:', paste(new_packages, collapse=', '), '\n')
    install.packages(new_packages, repos='https://cran.rstudio.com/')
} else {
    cat('All packages are already installed!\n')
}

# Verify installation
missing <- packages[!(packages %in% installed.packages()[,'Package'])]
if(length(missing) > 0) {
    cat('❌ Failed to install:', paste(missing, collapse=', '), '\n')
    quit(status=1)
} else {
    cat('✅ All packages installed successfully!\n')
}
"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Environment setup complete!"
    echo ""
    echo "You can now:"
    echo "1. Run the app locally: R -e \"shiny::runApp('app.R')\""
    echo "2. Deploy with Docker: ./deploy-docker.sh"
    echo "3. Deploy to shinyapps.io: see rsconnect/shinyapps.io/deploy.R"
    echo "4. Use the universal deployment script: ./deploy.sh"
else
    echo ""
    echo "❌ Setup failed. Please check the error messages above."
    exit 1
fi