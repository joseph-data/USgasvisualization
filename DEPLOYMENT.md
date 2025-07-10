# Deployment Guide for US Gas Visualization Shiny App

This guide provides multiple deployment options for the US Gas Visualization Shiny app.

## 🚀 Deployment Options

### Option 1: shinyapps.io (Easiest - Cloud Hosting)

**Prerequisites:**
- R installed on your local machine
- RStudio (recommended but not required)
- shinyapps.io account (free tier available)

**Steps:**

1. **Create a shinyapps.io account**
   - Go to https://www.shinyapps.io/
   - Sign up for a free account

2. **Get your deployment credentials**
   - Go to Account > Tokens
   - Copy your Name, Token, and Secret

3. **Set up your R environment**
   ```r
   # Install rsconnect package
   install.packages("rsconnect")
   
   # Configure your account (replace with your actual credentials)
   rsconnect::setAccountInfo(
     name = "your-account-name",
     token = "your-token-here",
     secret = "your-secret-here"
   )
   ```

4. **Deploy the app**
   ```r
   # Option A: Use the provided deployment script
   source("rsconnect/shinyapps.io/deploy.R")
   deploy_app()
   
   # Option B: Manual deployment
   rsconnect::deployApp(
     appDir = ".",
     appFiles = c("app.R", "renv.lock"),
     appName = "us-gas-visualization",
     forceUpdate = TRUE,
     launch.browser = TRUE
   )
   ```

5. **Access your app**
   - Your app will be available at: `https://your-account-name.shinyapps.io/us-gas-visualization/`

### Option 2: Docker (Self-hosted)

**Prerequisites:**
- Docker installed
- Docker Compose installed

**Steps:**

1. **Quick deployment using the provided script**
   ```bash
   ./deploy-docker.sh
   ```

2. **Manual deployment**
   ```bash
   # Build the image
   docker compose build
   
   # Start the container
   docker compose up -d
   
   # Check if it's running
   docker compose ps
   ```

3. **Access your app**
   - Your app will be available at: http://localhost:3838

**Docker management commands:**
```bash
# View logs
docker compose logs -f

# Stop the app
docker compose down

# Restart the app
docker compose restart

# Update and redeploy
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Option 3: Local Development

**Prerequisites:**
- R installed
- Required R packages

**Steps:**

1. **Install dependencies**
   ```r
   # Option A: Use renv (recommended)
   install.packages("renv")
   renv::restore()
   
   # Option B: Manual installation
   install.packages(c(
     "shiny", "tidyverse", "lubridate", 
     "scales", "viridis", "patchwork", "plotly"
   ))
   ```

2. **Run the app**
   ```r
   shiny::runApp("app.R")
   ```

3. **Access your app**
   - Your app will be available at: http://localhost:3838 (or the port shown in the R console)

## 🛠️ Troubleshooting

### Common Issues

1. **Package installation errors**
   - Make sure you have the latest version of R
   - Try installing packages one by one
   - Check your internet connection

2. **shinyapps.io deployment fails**
   - Verify your credentials are correct
   - Check your account usage limits
   - Ensure all required files are included

3. **Docker container won't start**
   - Check Docker logs: `docker compose logs`
   - Verify Docker is running
   - Check port 3838 is not already in use

4. **App loads but shows errors**
   - Check the data source URL is accessible
   - Verify all package dependencies are installed
   - Check R console/logs for error messages

## 📝 Configuration Options

### Environment Variables (Docker)
You can customize the deployment by setting environment variables in `docker-compose.yml`:

```yaml
environment:
  - SHINY_LOG_LEVEL=TRACE  # Change to INFO, WARN, or ERROR
  - SHINY_PORT=3838        # Change port if needed
```

### shinyapps.io Configuration
You can modify deployment settings in the `rsconnect/shinyapps.io/deploy.R` file:

```r
rsconnect::deployApp(
  appDir = ".",
  appFiles = c("app.R", "renv.lock"),
  appName = "your-custom-app-name",
  account = "your-account-name",
  server = "shinyapps.io",
  forceUpdate = TRUE,
  launch.browser = TRUE
)
```

## 🔒 Security Considerations

1. **Never commit sensitive credentials** to version control
2. **Use environment variables** for sensitive configuration
3. **Regularly update dependencies** to patch security vulnerabilities
4. **Monitor your deployed apps** for unusual activity

## 📊 Performance Tips

1. **Use caching** for expensive computations
2. **Optimize data loading** by pre-processing data
3. **Monitor resource usage** on your hosting platform
4. **Consider using a CDN** for static assets

## 🆘 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review the logs for error messages
3. Consult the official documentation:
   - [Shiny documentation](https://shiny.rstudio.com/)
   - [shinyapps.io documentation](https://docs.rstudio.com/shinyapps.io/)
   - [Docker documentation](https://docs.docker.com/)

## 🎯 Next Steps

After successful deployment, consider:

1. **Setting up monitoring** to track app performance
2. **Implementing user authentication** if needed
3. **Adding custom domains** for professional URLs
4. **Setting up automated deployments** with CI/CD pipelines