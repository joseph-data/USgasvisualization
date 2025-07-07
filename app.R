# app.R
library(shiny)
library(tidyverse)
library(lubridate)
library(scales)
library(viridis)
library(patchwork)
library(plotly)

# Pre‐load & prepare data once
prices <- read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-07-01/weekly_gas_prices.csv",
  col_types = cols(date = col_date(), price = col_double())
) %>%
  mutate(
    year  = year(date),
    month = month(date, label = TRUE, abbr = TRUE)
  ) %>%
  filter(
    (fuel == "diesel" & grade == "all") |
    (fuel == "gasoline" & grade == "regular" & formulation == "conventional")
  )

ui <- fluidPage(
  titlePanel("Weekly US Gas Prices Explorer"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "fuel_sel", "Select Fuel Types:",
        choices  = c("diesel", "gasoline"),
        selected = c("diesel", "gasoline")
      ),
      dateRangeInput(
        "date_rng", "Date Range:",
        start = min(prices$date),
        end   = max(prices$date)
      ),
      radioButtons(
        "plot_type", "Choose Plot:",
        choices  = list(
          "Annual Trend"        = "annual",
          "Monthly Seasonality" = "season",
          "Weekly Volatility"   = "volatility",
          "Diesel vs Gasoline"  = "corr"
        ),
        selected = "annual"
      )
    ),
    mainPanel(
      plotlyOutput("gas_plot", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  filtered <- reactive({
    prices %>%
      filter(
        fuel %in% input$fuel_sel,
        date >= input$date_rng[1],
        date <= input$date_rng[2]
      )
  })

  output$gas_plot <- renderPlotly({
    df <- filtered()

    if (input$plot_type == "annual") {
      annual <- df %>%
        group_by(year, fuel) %>%
        summarize(avg_price = mean(price), .groups = "drop")

      p <- ggplot(annual, aes(year, avg_price, color = fuel)) +
        geom_line(size = 1.2) + geom_point(size = 2) +
        scale_x_continuous(breaks = seq(min(annual$year), max(annual$year), by = 5)) +
        scale_color_viridis_d(end = .8) +
        labs(
          title = "Average Annual Gas Prices",
          x     = "Year", 
          y     = "Avg Price (USD)", 
          color = "Fuel"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    } else if (input$plot_type == "season") {
      p <- ggplot(df, aes(month, price, fill = fuel)) +
        geom_boxplot(alpha = 0.8, outlier.shape = NA) +
        scale_fill_viridis_d(option = "C") +
        labs(
          title = "Monthly Price Distribution",
          x     = "Month", 
          y     = "Price (USD)"
        ) +
        theme_minimal() +
        theme(legend.position = "top")

    } else if (input$plot_type == "volatility") {
      diffs <- df %>%
        arrange(date) %>%
        group_by(fuel) %>%
        mutate(delta = price - lag(price)) %>%
        drop_na()

      p <- ggplot(diffs, aes(date, delta, color = fuel)) +
        geom_hline(yintercept = 0, color = "grey70") +
        geom_line(alpha = 0.6) +
        scale_color_viridis_d(option = "A", end = .7) +
        labs(
          title = "Weekly Price Change",
          x     = "Date", 
          y     = "Δ Price (USD)"
        ) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))

    } else {
      wide <- df %>%
        select(date, fuel, price) %>%
        pivot_wider(names_from = fuel, values_from = price)

      p <- ggplot(wide, aes(gasoline, diesel, color = date)) +
        geom_point(alpha = 0.7) +
        scale_color_viridis_c() +
        geom_smooth(method = "lm", color = "black", se = FALSE) +
        labs(
          title = "Diesel vs. Regular Gasoline",
          x     = "Gasoline Price (USD)", 
          y     = "Diesel Price (USD)"
        ) +
        theme_minimal()
    }

    ggplotly(p) %>% layout(legend = list(orientation = "h", x = 0.1, y = -0.2))
  })
}

shinyApp(ui, server)
