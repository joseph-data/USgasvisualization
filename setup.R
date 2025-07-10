#!/usr/bin/env Rscript

# setup.R - Setup script for US Gas Visualization Shiny App

cat("🔧 Setting up US Gas Visualization Shiny App\n")
cat("============================================\n\n")

# Function to install packages if not already installed
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE)) {
    cat(paste("Installing", pkg, "...\n"))
    install.packages(pkg, dependencies = TRUE)
    library(pkg, character.only = TRUE)
  } else {
    cat(paste("✓", pkg, "already installed\n"))
  }
}

# List of required packages
required_packages <- c(
  "shiny",
  "tidyverse", 
  "lubridate",
  "scales",
  "viridis",
  "patchwork",
  "plotly",
  "rsconnect"  # For deployment
)

cat("📦 Installing required packages...\n")
cat("==================================\n")

# Install packages
for (pkg in required_packages) {
  install_if_missing(pkg)
}

cat("\n🎯 Setup complete!\n")
cat("==================\n\n")

cat("Next steps:\n")
cat("1. To run locally: Rscript local-deploy.R\n")
cat("2. To deploy to shinyapps.io: Rscript deploy.R\n")
cat("3. To use shell script: ./deploy.sh local\n")
cat("4. For Docker: ./deploy.sh docker\n\n")

cat("📖 For detailed deployment instructions, see DEPLOYMENT.md\n")

# Test if the app can be loaded
cat("\n🧪 Testing app loading...\n")
tryCatch({
  source("app.R", local = TRUE)
  cat("✅ App loaded successfully!\n")
}, error = function(e) {
  cat("❌ Error loading app:", conditionMessage(e), "\n")
  cat("Please check the error and try again.\n")
})

cat("\n🚀 Ready to deploy!\n")