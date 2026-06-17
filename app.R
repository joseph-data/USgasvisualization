library(shiny)
library(bslib)
library(tidyverse)
library(lubridate)
library(scales)
library(plotly)

# Brand colours are intentional — suppress WCAG contrast warnings in devmode
options(bslib.color_contrast_warnings = FALSE)

# ── Palette derived from _brand.yml ──────────────────────────────────────────
fuel_pal  <- c("diesel" = "#4D6CFA", "gasoline" = "#BA274A")
fuel_labs <- c("diesel" = "Diesel",  "gasoline" = "Gasoline")

# ── Load & prepare data ───────────────────────────────────────────────────────
prices <- read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-07-01/weekly_gas_prices.csv",
  col_types = cols(date = col_date(), price = col_double())
) |>
  mutate(
    year  = year(date),
    month = month(date, label = TRUE, abbr = TRUE)
  ) |>
  filter(
    (fuel == "diesel"   & grade == "all") |
    (fuel == "gasoline" & grade == "regular" & formulation == "conventional")
  )

year_range <- range(prices$year)

# ── Theme ─────────────────────────────────────────────────────────────────────
app_theme <- bs_theme(brand = "_brand.yml")

plot_theme <- theme_minimal(base_size = 13) +
  theme(
    plot.background   = element_rect(fill = "#F9F7F1", colour = NA),
    panel.background  = element_rect(fill = "#F9F7F1", colour = NA),
    panel.grid.minor  = element_blank(),
    panel.grid.major  = element_line(colour = "#E8E4DA"),
    text              = element_text(colour = "#1C2826", family = "sans"),
    plot.title        = element_text(face = "bold", size = 14, colour = "#0C0A3E"),
    axis.title        = element_text(size = 11),
    legend.title      = element_blank(),
    legend.position   = "top",
    legend.key.size   = unit(0.6, "cm")
  )

# ── UI ────────────────────────────────────────────────────────────────────────
ui <- page_sidebar(
  title = "US Gas Prices Explorer",
  theme = app_theme,

  sidebar = sidebar(
    width = 260,

    checkboxGroupInput(
      "fuel_sel", "Fuel type",
      choices  = c("Diesel" = "diesel", "Gasoline" = "gasoline"),
      selected = c("diesel", "gasoline")
    ),

    sliderInput(
      "year_rng", "Year range",
      min   = year_range[1],
      max   = year_range[2],
      value = year_range,
      step  = 1,
      sep   = ""
    ),

    hr(),

    actionButton(
      "reset", "Reset filters",
      class = "btn-outline-secondary btn-sm w-100"
    ),

    hr(),

    p(
      class = "small text-muted",
      "Weekly retail prices from the U.S. EIA via",
      tags$a("TidyTuesday", href = "https://github.com/rfordatascience/tidytuesday"),
      "(2025-07-01). Prices in nominal USD per gallon."
    )
  ),

  # KPI row
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box(
      title    = "Latest diesel price",
      value    = textOutput("kpi_diesel"),
      showcase = icon("gas-pump"),
      theme    = "primary"
    ),
    value_box(
      title    = "Latest gasoline price",
      value    = textOutput("kpi_gasoline"),
      showcase = icon("car"),
      theme    = value_box_theme(bg = "#BA274A")
    ),
    value_box(
      title    = "Diesel premium",
      value    = textOutput("kpi_premium"),
      showcase = icon("arrow-trend-up"),
      theme    = value_box_theme(bg = "#2A2E45")
    )
  ),

  # Chart tabs
  navset_card_tab(
    full_screen = TRUE,
    height      = "520px",
    nav_panel("Annual trend",    plotlyOutput("plot_annual",     height = "430px")),
    nav_panel("Seasonality",     plotlyOutput("plot_season",     height = "430px")),
    nav_panel("Volatility",      plotlyOutput("plot_volatility", height = "430px")),
    nav_panel("Diesel vs. gas",  plotlyOutput("plot_corr",       height = "430px")),
    nav_spacer(),
    nav_item(tags$small(class = "text-muted me-2", textOutput("obs_count", inline = TRUE)))
  )
)

# ── Server ────────────────────────────────────────────────────────────────────
server <- function(input, output, session) {

  # Reset button
  observeEvent(input$reset, {
    updateCheckboxGroupInput(session, "fuel_sel",
                             selected = c("diesel", "gasoline"))
    updateSliderInput(session, "year_rng", value = year_range)
  })

  # Filtered data
  filtered <- reactive({
    req(length(input$fuel_sel) > 0)
    prices |>
      filter(
        fuel %in% input$fuel_sel,
        year >= input$year_rng[1],
        year <= input$year_rng[2]
      )
  })

  # Latest prices (always from the full dataset, not filtered by year)
  latest <- reactive({
    prices |>
      filter(fuel %in% input$fuel_sel) |>
      group_by(fuel) |>
      slice_max(date, n = 1) |>
      ungroup()
  })

  # KPIs
  output$kpi_diesel <- renderText({
    val <- latest() |> filter(fuel == "diesel") |> pull(price)
    if (length(val) == 0) "—" else dollar(val)
  })

  output$kpi_gasoline <- renderText({
    val <- latest() |> filter(fuel == "gasoline") |> pull(price)
    if (length(val) == 0) "—" else dollar(val)
  })

  output$kpi_premium <- renderText({
    d <- latest() |> filter(fuel == "diesel")   |> pull(price)
    g <- latest() |> filter(fuel == "gasoline") |> pull(price)
    if (length(d) == 0 || length(g) == 0) "—"
    else paste0(dollar(d - g), " / gal")
  })

  output$obs_count <- renderText({
    n <- nrow(filtered())
    paste0(format(n, big.mark = ","), " weekly observations")
  })

  # ── Annual trend ─────────────────────────────────────────────────────────
  output$plot_annual <- renderPlotly({
    annual <- filtered() |>
      group_by(year, fuel) |>
      summarise(avg_price = mean(price, na.rm = TRUE), .groups = "drop") |>
      mutate(tip = paste0(fuel_labs[fuel], " ", year,
                          ": ", dollar(round(avg_price, 2))))

    validate(need(nrow(annual) > 0, "No data for the selected filters."))

    events <- tibble(
      year  = c(2008, 2020, 2022),
      label = c("2008 crisis", "COVID-19", "Ukraine war")
    ) |> filter(year >= input$year_rng[1], year <= input$year_rng[2])

    # text must NOT be in global aes — it prevents geom_line from rendering in ggplotly.
    # Put it only on geom_point; geom_vline is replaced by plotly layout shapes below.
    p <- ggplot(annual, aes(year, avg_price, colour = fuel)) +
      geom_line(linewidth = 1.1) +
      suppressWarnings(geom_point(aes(text = tip), size = 2.2)) +
      scale_colour_manual(values = fuel_pal, labels = fuel_labs) +
      scale_x_continuous(breaks = seq(year_range[1], year_range[2], by = 5)) +
      scale_y_continuous(labels = dollar_format(), expand = expansion(mult = c(0.05, 0.1))) +
      labs(title = "Average annual retail prices", x = NULL, y = "USD / gallon") +
      plot_theme

    event_shapes <- lapply(events$year, \(yr) list(
      type = "line", x0 = yr, x1 = yr, xref = "x",
      y0 = 0, y1 = 1, yref = "paper",
      line = list(color = "#2A2E45", width = 1, dash = "dash")
    ))

    event_labels <- lapply(seq_len(nrow(events)), \(i) list(
      x = events$year[i], y = 0.98, xref = "x", yref = "paper",
      text = events$label[i], showarrow = FALSE,
      xanchor = "right", yanchor = "top",
      textangle = -90,
      font = list(size = 10, color = "#666666")
    ))

    ggplotly(p, tooltip = "text") |>
      layout(
        shapes      = event_shapes,
        annotations = event_labels,
        legend      = list(orientation = "h", x = 0, y = -0.12)
      ) |>
      config(displayModeBar = FALSE)
  })

  # ── Seasonality ───────────────────────────────────────────────────────────
  output$plot_season <- renderPlotly({
    df <- filtered() |>
      mutate(tip = paste0(fuel_labs[fuel], " — ", month,
                          "\nPrice: ", dollar(round(price, 2))))
    validate(need(nrow(df) > 0, "No data for the selected filters."))

    p <- ggplot(df, aes(month, price, colour = fuel,
                         fill = after_scale(alpha(colour, 0.2)),
                         text = tip)) +
      geom_boxplot(linewidth = 0.5, outlier.shape = NA) +
      scale_colour_manual(values = fuel_pal, labels = fuel_labs) +
      scale_y_continuous(labels = dollar_format()) +
      labs(title = "Monthly price distribution", x = NULL, y = "USD / gallon") +
      plot_theme

    ggplotly(p, tooltip = "text") |>
      layout(boxmode = "group",
             legend = list(orientation = "h", x = 0, y = -0.12)) |>
      config(displayModeBar = FALSE)
  })

  # ── Volatility ───────────────────────────────────────────────────────────
  # Built with plot_ly() directly — ggplotly() drops traces on Date x + colour + text
  output$plot_volatility <- renderPlotly({
    diffs <- filtered() |>
      arrange(date) |>
      group_by(fuel) |>
      mutate(delta = price - lag(price)) |>
      ungroup() |>
      drop_na(delta)

    validate(need(nrow(diffs) > 0, "No data for the selected filters."))

    fuels <- intersect(c("diesel", "gasoline"), unique(diffs$fuel))

    plt <- plot_ly()

    for (f in fuels) {
      d <- filter(diffs, fuel == f)
      plt <- add_trace(plt,
        data = d, x = ~date, y = ~delta,
        type = "scatter", mode = "lines",
        name = fuel_labs[f],
        line = list(color = fuel_pal[f], width = 1.5),
        opacity = 0.7,
        hovertemplate = paste0(
          "<b>", fuel_labs[f], "</b><br>",
          "%{x|%b %d, %Y}<br>",
          "Change: %{y:+$.3f}<extra></extra>"
        )
      )
    }

    layout(plt,
      title = list(
        text   = "<b>Week-on-week price change</b>",
        x      = 0, xanchor = "left",
        font   = list(size = 14, color = "#0C0A3E")
      ),
      xaxis = list(title = NULL, gridcolor = "#E8E4DA", showgrid = TRUE),
      yaxis = list(
        title      = "Δ USD / gallon",
        tickprefix = "$",
        gridcolor  = "#E8E4DA",
        showgrid   = TRUE,
        zeroline   = FALSE
      ),
      shapes = list(list(
        type = "line", x0 = 0, x1 = 1, xref = "paper",
        y0 = 0, y1 = 0, yref = "y",
        line = list(color = "#2A2E45", width = 1)
      )),
      legend       = list(orientation = "h", x = 0, y = -0.1),
      font         = list(color = "#1C2826"),
      paper_bgcolor = "#F9F7F1",
      plot_bgcolor  = "#F9F7F1",
      margin       = list(l = 60, r = 20, t = 50, b = 40)
    ) |>
    config(displayModeBar = FALSE)
  })

  # ── Correlation ───────────────────────────────────────────────────────────
  output$plot_corr <- renderPlotly({
    wide <- filtered() |>
      select(date, fuel, price) |>
      pivot_wider(names_from = fuel, values_from = price) |>
      drop_na()

    validate(need(
      all(c("diesel", "gasoline") %in% names(wide)),
      "Select both fuel types to view the correlation chart."
    ))
    validate(need(nrow(wide) > 2, "Not enough data."))

    cor_val <- round(cor(wide$diesel, wide$gasoline), 3)

    p <- ggplot(wide, aes(gasoline, diesel, colour = year(date),
                           text = paste0(date, "\nGasoline: ", dollar(round(gasoline, 2)),
                                         "\nDiesel: ",   dollar(round(diesel, 2))))) +
      geom_point(alpha = 0.45, size = 1.2) +
      geom_smooth(method = "lm", formula = y ~ x, colour = "#0C0A3E", linewidth = 1, se = FALSE) +
      scale_colour_gradient(low = "#BA274A", high = "#4D6CFA", name = "Year") +
      scale_x_continuous(labels = dollar_format()) +
      scale_y_continuous(labels = dollar_format()) +
      annotate("text", x = Inf, y = -Inf,
               label  = paste0("r = ", cor_val),
               hjust  = 1.1, vjust = -0.6,
               size   = 3.5, colour = "#2A2E45", fontface = "italic") +
      labs(title = "Diesel vs. regular gasoline",
           x = "Gasoline (USD / gal)", y = "Diesel (USD / gal)") +
      plot_theme

    ggplotly(p, tooltip = "text") |>
      layout(legend = list(orientation = "v", x = 1.02, y = 0.5)) |>
      config(displayModeBar = FALSE)
  })

  # Lazy-render hidden tabs
  outputOptions(output, "plot_season",     suspendWhenHidden = TRUE)
  outputOptions(output, "plot_volatility", suspendWhenHidden = TRUE)
  outputOptions(output, "plot_corr",       suspendWhenHidden = TRUE)
}

shinyApp(ui, server)
