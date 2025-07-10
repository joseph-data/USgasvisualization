# init.R for Heroku deployment
# This file installs required packages

# Install packages
install.packages("shiny")
install.packages("tidyverse") 
install.packages("lubridate")
install.packages("scales")
install.packages("viridis")
install.packages("patchwork")
install.packages("plotly")

# Alternative: Use renv for reproducible installs
# if (!require("renv")) install.packages("renv")
# renv::restore()