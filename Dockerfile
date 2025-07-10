# Dockerfile for US Gas Visualization Shiny App
FROM rocker/shiny:4.3.0

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libgdal-dev \
    libudunits2-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /srv/shiny-server

# Copy renv.lock first for better caching
COPY renv.lock .

# Install R packages using renv for reproducibility
RUN R -e "install.packages('renv')"
RUN R -e "renv::restore()"

# Alternative: Install packages directly
# RUN R -e "install.packages(c('shiny', 'tidyverse', 'lubridate', 'scales', 'viridis', 'patchwork', 'plotly'), repos='https://cran.rstudio.com/')"

# Copy app files
COPY app.R .

# Set proper permissions
RUN chown -R shiny:shiny /srv/shiny-server

# Expose port
EXPOSE 3838

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3838/ || exit 1

# Start Shiny Server
CMD ["/usr/bin/shiny-server"]