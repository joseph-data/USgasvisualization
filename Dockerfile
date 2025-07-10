# Use official R base image
FROM rocker/shiny:4.3.2

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /srv/shiny-server

# Install required R packages
RUN R -e "install.packages(c('shiny', 'dplyr', 'ggplot2', 'readr', 'tidyr', 'lubridate', 'scales', 'viridis', 'patchwork', 'plotly'), repos='https://cran.rstudio.com/')"

# Copy the app files
COPY app.R ./

# Expose port 3838 for Shiny
EXPOSE 3838

# Create a simple start script
RUN echo '#!/bin/bash\nR -e "shiny::runApp(host=\"0.0.0.0\", port=3838)"' > /usr/local/bin/start-app.sh && \
    chmod +x /usr/local/bin/start-app.sh

# Run the app
CMD ["/usr/local/bin/start-app.sh"]