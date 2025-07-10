#!/usr/bin/env Rscript

# local-deploy.R
# Script to run the Shiny app locally for development and testing

# Check if required packages are installed
required_packages <- c("shiny", "tidyverse", "lubridate", "scales", "viridis", "patchwork", "plotly")

# Install missing packages
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(missing_packages) > 0) {
  message("Installing missing packages: ", paste(missing_packages, collapse = ", "))
  install.packages(missing_packages)
}

# Load required libraries
library(shiny)

# Check if app.R exists
if (!file.exists("app.R")) {
  stop("app.R not found in current directory. Please ensure you are in the correct directory.")
}

# Run the app
message("Starting US Gas Visualization Shiny App...")
message("The app will open in your default web browser.")
message("Press Ctrl+C to stop the app.")

# Run the app with options for better development experience
shiny::runApp(
  appDir = ".",
  port = 3838,
  host = "127.0.0.1",
  launch.browser = TRUE,
  display.mode = "normal"
)