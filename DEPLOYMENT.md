# 🚀 Deployment Guide for US Gas Visualization Shiny App

This guide will help you deploy the `app.R` Shiny application to various platforms.

## 📋 Prerequisites

Before deploying, ensure you have:
- R installed (version 4.0 or higher)
- All required packages installed (see `renv.lock` or install via `renv::restore()`)
- Internet connection for fetching data

## 🌐 Deployment Options

### Option 1: shinyapps.io (Recommended)

**shinyapps.io** is the easiest and most popular platform for deploying Shiny apps.

#### Step 1: Set up shinyapps.io account
1. Go to [shinyapps.io](https://www.shinyapps.io/)
2. Create a free account
3. Note your account name, token, and secret

#### Step 2: Install rsconnect
```r
install.packages("rsconnect")
library(rsconnect)
```

#### Step 3: Configure your account
```r
rsconnect::setAccountInfo(
  name = "your-account-name",
  token = "your-token-here", 
  secret = "your-secret-here"
)
```

#### Step 4: Deploy using the provided script
```r
# Option A: Use the deploy script
source("deploy.R")

# Option B: Manual deployment
rsconnect::deployApp(
  appDir = ".",
  appFiles = c("app.R", "renv.lock"),
  appName = "usgasvisualization",
  appTitle = "US Gas Prices Visualization",
  launch.browser = TRUE
)
```

### Option 2: Shiny Server (Self-hosted)

#### Requirements
- Linux server with R installed
- Shiny Server installed

#### Steps
1. Install Shiny Server on your server
2. Copy `app.R` to `/srv/shiny-server/usgasvisualization/`
3. Install required packages on the server
4. Access via `http://your-server-ip:3838/usgasvisualization/`

### Option 3: Docker Deployment

#### Create Dockerfile
```dockerfile
FROM rocker/shiny:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev

# Install R packages
RUN R -e "install.packages(c('shiny', 'tidyverse', 'lubridate', 'scales', 'viridis', 'patchwork', 'plotly'), repos='https://cran.rstudio.com/')"

# Copy app files
COPY app.R /srv/shiny-server/
COPY renv.lock /srv/shiny-server/

# Expose port
EXPOSE 3838

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]
```

#### Build and run
```bash
docker build -t usgasvisualization .
docker run -p 3838:3838 usgasvisualization
```

### Option 4: Heroku Deployment

#### Requirements
- Heroku account
- Heroku CLI installed
- Git repository

#### Steps
1. Create these files in your repository:
   - `init.R` (install packages)
   - `run.R` (run the app)
   - `app.json` (Heroku configuration)

2. Deploy to Heroku:
```bash
heroku create your-app-name
git push heroku main
```

## 🔧 Configuration Files

The following files are included to help with deployment:

- **`deploy.R`**: Automated deployment script for shinyapps.io
- **`manifest.json`**: Deployment manifest with package dependencies
- **`renv.lock`**: Lockfile for reproducible package versions

## 📝 Deployment Checklist

Before deploying, verify:
- [ ] All required packages are listed in `renv.lock`
- [ ] App runs locally without errors
- [ ] Data URL is accessible (internet connection required)
- [ ] Account credentials are configured (for shinyapps.io)
- [ ] App files are in the correct directory structure

## 🐛 Troubleshooting

### Common Issues

1. **Package installation errors**
   - Ensure all packages in `renv.lock` are available
   - Try `renv::restore()` to install exact versions

2. **Data loading errors**
   - Check internet connectivity
   - Verify the TidyTuesday data URL is accessible

3. **Memory issues**
   - Consider using a paid shinyapps.io plan for more resources
   - Optimize data processing in the app

4. **Deployment timeout**
   - Increase timeout settings in deployment script
   - Use `forceUpdate = TRUE` to overwrite existing deployments

### Getting Help

- [Shiny deployment guide](https://shiny.rstudio.com/articles/deployment-web.html)
- [shinyapps.io documentation](https://docs.rstudio.com/shinyapps.io/)
- [RStudio Community](https://community.rstudio.com/)

## 🎯 Quick Start

For the fastest deployment to shinyapps.io:

```r
# 1. Install rsconnect
install.packages("rsconnect")

# 2. Set up your account (get credentials from shinyapps.io)
rsconnect::setAccountInfo(name="your-account", token="your-token", secret="your-secret")

# 3. Deploy
source("deploy.R")
```

Your app will be available at: `https://your-account.shinyapps.io/usgasvisualization/`

---

**Note**: The app fetches data from the internet, so ensure your deployment environment has internet access.