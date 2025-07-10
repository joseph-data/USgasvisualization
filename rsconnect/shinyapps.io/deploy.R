# Deployment script for shinyapps.io
# This script helps deploy the Shiny app to shinyapps.io

# Install required packages for deployment
if (!require("rsconnect")) {
  install.packages("rsconnect")
}

# Load rsconnect library
library(rsconnect)

# Set up account (you'll need to do this once)
# Instructions:
# 1. Create account at https://www.shinyapps.io/
# 2. Get your token and secret from Account > Tokens
# 3. Run the following command with your actual token and secret:
# rsconnect::setAccountInfo(
#   name = "your-account-name",
#   token = "your-token-here",
#   secret = "your-secret-here"
# )

# Deploy the app
# Note: Run this from the root directory of your project
deploy_app <- function(app_name = "us-gas-visualization") {
  # Deploy the app
  rsconnect::deployApp(
    appDir = ".",
    appFiles = c("app.R", "renv.lock"),
    appName = app_name,
    account = NULL,  # Uses default account
    server = "shinyapps.io",
    forceUpdate = TRUE,
    launch.browser = TRUE
  )
}

# Uncomment and run the following line to deploy:
# deploy_app()

# Instructions for deployment:
# 1. Set up your shinyapps.io account credentials (see above)
# 2. Run: deploy_app()
# 3. Your app will be available at: https://your-account-name.shinyapps.io/us-gas-visualization/

cat("Deployment script ready. Follow the instructions in the comments to deploy.\n")