# Deploy script for USgasvisualization Shiny app
# This script deploys the app to shinyapps.io

# Load required packages
if (!require("rsconnect")) {
  install.packages("rsconnect")
  library(rsconnect)
}

# Deploy the application
# Note: You need to set up your shinyapps.io account first
# Run: rsconnect::setAccountInfo(name="your-account-name", token="your-token", secret="your-secret")

# Deploy to shinyapps.io
rsconnect::deployApp(
  appDir = ".",
  appFiles = c("app.R", "renv.lock"),
  appName = "usgasvisualization",
  appTitle = "US Gas Prices Visualization",
  launch.browser = TRUE,
  forceUpdate = TRUE
)

# Alternative: Deploy with specific account
# rsconnect::deployApp(
#   appDir = ".",
#   appFiles = c("app.R", "renv.lock"),
#   appName = "usgasvisualization",
#   appTitle = "US Gas Prices Visualization",
#   account = "your-account-name",
#   launch.browser = TRUE,
#   forceUpdate = TRUE
# )