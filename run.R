# run.R for Heroku deployment
# This file runs the Shiny app

# Load required libraries
library(shiny)

# Get port from environment variable or default to 3838
port <- Sys.getenv('PORT', 3838)

# Run the Shiny app
shiny::runApp(
  appDir = ".",
  host = "0.0.0.0",
  port = as.numeric(port)
)