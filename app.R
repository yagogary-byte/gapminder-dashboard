# =============================================================
# DASHBOARD INTERACTIVO - GAPMINDER
# Producto Académico Colaborativo
# Curso: Programación en R
# =============================================================

# ---- 1. PAQUETES ----
library(shiny)
library(ggplot2)
library(dplyr)
library(gapminder)
library(plotly)
library(DT)

# ---- 2. DATOS GLOBALES ----
data("gapminder")
paises     <- sort(unique(gapminder$country))
continentes <- c("Todos", sort(unique(gapminder$continent)))
anios      <- sort(unique(gapminder$year))

# ---- 3. UI ----
ui <- fluidPage(

  # Título y CSS personalizado
  tags$head(
    tags$style(HTML("
      body { font-family: 'Segoe UI', sans-serif; background-color: #f8f9fa; }
      .navbar-default { background-color: #2c3e50; border-color: #2c3e50; }
      .navbar-default .navbar-brand,
      .navbar-default .navbar-nav > li > a { color: #ecf0f1 !important; }
      .well { background-color: #ffffff; border: 1px solid #dee2e6; border-radius: 8px; }
      .kpi-box { background:#fff; border-radius:10px; padding:18px 14px;
                 text-align:center; border-left:5px solid #1abc9c;
                 box-shadow:0 2px 8px rgba(0,0,0,.07); margin-bottom:14px; }
      .kpi-val { font-size:28px; font-weight:700; color:#2c3e50; }
      .kpi-lbl { font-size:12px; color:#7f8c8d; margin-top:4px; }
      h4 { color:#2c3e50; font-weight:600; }
      .tab-content { padding-top: 18px; }
    "))
  ),

  # Cabecera
  titlePanel(
    div(
      style = "background:#2c3e50; color:white; padding:16px 24px;
               border-radius:8px; margin-bottom:18px;",
      h2(style = "margin:0; font-size:22px;",
         "\U0001F30D Dashboard Gapminder — Desarrollo Humano Mundial"),
      p(style = "margin:4px 0 0; font-size:13px; color:#bdc3c7;",
        "Exploración interactiva de esperanza de vida, PIB per cápita y población (1952–2007)")
    )
  ),

  # Layout principal
  sidebarLayout(

    # ---- PANEL LATERAL (filtros) ----
    sidebarPanel(
      width = 3,

      h4("\U0001F50D Filtros"),

      selectInput("continente", "Continente:",
                  choices  = continentes,
                  selected = "Todos"),

      uiOutput("ui_pais"),

      sliderInput("anio", "Año:",
                  min   = min(anios),
                  max   = max(anios),
                  value = c(min(anios), max(anios)),
                  step  = 5,
                  sep   = ""),

      hr(),
      h4("\U0001F4CA KPIs del año seleccionado"),
      uiOutput("kpis"),

      hr(),
      p(style = "font-size:11px; color:#95a5a6;",
        "Fuente: Gapminder Foundation. Paquete {gapminder} de R.")
    ),

    # ---- PANEL PRINCIPAL (pestañas) ----
    mainPanel(
      width = 9,
      tabsetPanel(
        id = "tabs",

        # --- Pestaña 1: Tendencias ---
        tabPanel(
          "\U0001F4C8 Tendencias",
          fluidRow(
            column(6, plotlyOutput("plot_vida",   height = "320px")),
            column(6, plotlyOutput("plot_gdp",    height = "320px"))
          ),
          fluidRow(
            column(12, plotlyOutput("plot_pop",   height = "260px"))
          )
        ),

        # --- Pestaña 2: Comparación continental ---
        tabPanel(
          "\U0001F5FA\uFE0F Continentes",
          fluidRow(
            column(6, plotlyOutput("plot_boxvida", height = "340px")),
            column(6, plotlyOutput("plot_boxgdp",  height = "340px"))
          ),
          fluidRow(
            column(12, plotlyOutput("plot_burbuja", height = "380px"))
          )
        ),

        # --- Pestaña 3: Modelo estadístico ---
        tabPanel(
          "\U0001F9EE Modelo",
          fluidRow(
            column(8,  plotlyOutput("plot_regresion", height = "380px")),
            column(4,  verbatimTextOutput("resumen_modelo"))
          ),
          fluidRow(
            column(12, plotlyOutput("plot_residuos", height = "260px"))
          )
        ),

        # --- Pestaña 4: Tabla de datos ---
        tabPanel(
          "\U0001F4CB Datos",
          DTOutput("tabla_datos")
        )
      ) # fin tabsetPanel
    )   # fin mainPanel
  )     # fin sidebarLayout
)       # fin fluidPage

# ---- 4. SERVER ----
server <- function(input, output, session) {

  # -- UI dinámico: lista de países según continente --
  output$ui_pais <- renderUI({
    if (input$continente == "Todos") {
      lista <- paises
    } else {
      lista <- gapminder %>%
        filter(continent == input$continente) %>%
        pull(country) %>% unique() %>% sort()
    }
    selectInput("pais", "País (para tendencias):",
                choices  = lista,
                selected = "Peru")
  })

  # -- Datos filtrados por continente + rango de años --
  datos_cont <- reactive({
    df <- gapminder %>%
      filter(year >= input$anio[1], year <= input$anio[2])
    if (input$continente != "Todos") {
      df <- df %>% filter(continent == input$continente)
    }
    df
  })

  # -- Datos de UN país a lo largo del tiempo --
  datos_pais <- reactive({
    req(input$pais)
    gapminder %>%
      filter(country == input$pais,
             year >= input$anio[1],
             year <= input$anio[2])
  })

  # -- Datos del último año seleccionado para KPIs --
  datos_ultimo <- reactive({
    gapminder %>%
      filter(country == req(input$pais),
             year == input$anio[2])
  })

  # ---- KPIs ----
  output$kpis <- renderUI({
    d <- datos_ultimo()
    if (nrow(d) == 0) return(p("Sin datos"))
    tagList(
      div(class = "kpi-box",
          div(class = "kpi-val", round(d$lifeExp, 1)),
          div(class = "kpi-lbl", "Esperanza de vida (años)")),
      div(class = "kpi-box", style = "border-color:#3498db;",
          div(class = "kpi-val", paste0("$", formatC(round(d$gdpPercap), big.mark = ","))),
          div(class = "kpi-lbl", "PIB per cápita (USD)")),
      div(class = "kpi-box", style = "border-color:#e74c3c;",
          div(class = "kpi-val", formatC(d$pop, format = "d", big.mark = ",")),
          div(class = "kpi-lbl", "Población"))
    )
  })

  # ===== PESTAÑA 1: TENDENCIAS =====

  output$plot_vida <- renderPlotly({
    p <- ggplot(datos_pais(), aes(x = year, y = lifeExp)) +
      geom_line(color = "#1abc9c", size = 1.2) +
      geom_point(color = "#16a085", size = 3) +
      labs(title = paste("Esperanza de vida —", input$pais),
           x = "Año", y = "Años") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p) %>% layout(hovermode = "x unified")
  })

  output$plot_gdp <- renderPlotly({
    p <- ggplot(datos_pais(), aes(x = year, y = gdpPercap)) +
      geom_area(fill = "#3498db", alpha = 0.25) +
      geom_line(color = "#2980b9", size = 1.2) +
      geom_point(color = "#1a5276", size = 3) +
      labs(title = paste("PIB per cápita —", input$pais),
           x = "Año", y = "USD") +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p) %>% layout(hovermode = "x unified")
  })

  output$plot_pop <- renderPlotly({
    p <- ggplot(datos_pais(), aes(x = year, y = pop / 1e6)) +
      geom_col(fill = "#e67e22", alpha = 0.85) +
      labs(title = paste("Población —", input$pais),
           x = "Año", y = "Millones de habitantes") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p)
  })

  # ===== PESTAÑA 2: CONTINENTES =====

  output$plot_boxvida <- renderPlotly({
    p <- ggplot(datos_cont(), aes(x = continent, y = lifeExp, fill = continent)) +
      geom_boxplot(alpha = 0.7, outlier.colour = "#e74c3c") +
      labs(title = "Esperanza de vida por continente",
           x = NULL, y = "Años") +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none",
            plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p)
  })

  output$plot_boxgdp <- renderPlotly({
    p <- ggplot(datos_cont(), aes(x = continent, y = gdpPercap, fill = continent)) +
      geom_boxplot(alpha = 0.7, outlier.colour = "#e74c3c") +
      scale_y_log10(labels = scales::comma) +
      labs(title = "PIB per cápita por continente (escala log)",
           x = NULL, y = "USD (log)") +
      theme_minimal(base_size = 12) +
      theme(legend.position = "none",
            plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p)
  })

  output$plot_burbuja <- renderPlotly({
    df_ult <- datos_cont() %>% filter(year == max(year))
    p <- ggplot(df_ult,
                aes(x = gdpPercap, y = lifeExp,
                    size = pop / 1e6, color = continent,
                    text = paste0("<b>", country, "</b><br>",
                                  "PIB: $", round(gdpPercap), "<br>",
                                  "Vida: ", round(lifeExp, 1), " años<br>",
                                  "Pob: ", round(pop / 1e6, 1), "M"))) +
      geom_point(alpha = 0.7) +
      scale_x_log10(labels = scales::comma) +
      scale_size(range = c(3, 20)) +
      labs(title = paste("Relación PIB vs Esperanza de Vida —", max(datos_cont()$year)),
           x = "PIB per cápita (USD, escala log)",
           y = "Esperanza de vida (años)",
           color = "Continente", size = "Pob. (M)") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p, tooltip = "text")
  })

  # ===== PESTAÑA 3: MODELO ESTADÍSTICO =====

  modelo <- reactive({
    df <- datos_cont() %>%
      mutate(log_gdp = log(gdpPercap))
    lm(lifeExp ~ log_gdp + year + continent, data = df)
  })

  output$plot_regresion <- renderPlotly({
    df <- datos_cont() %>% mutate(log_gdp = log(gdpPercap))
    p <- ggplot(df, aes(x = log_gdp, y = lifeExp, color = continent)) +
      geom_point(alpha = 0.4, size = 1.5) +
      geom_smooth(method = "lm", se = TRUE, size = 1.1) +
      labs(title  = "Regresión: log(PIB) vs Esperanza de vida",
           subtitle = "Una línea por continente",
           x = "log(PIB per cápita)",
           y = "Esperanza de vida (años)",
           color = "Continente") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p)
  })

  output$resumen_modelo <- renderPrint({
    cat("=== RESUMEN DEL MODELO ===\n")
    cat("lifeExp ~ log(gdpPercap) + year + continent\n\n")
    s <- summary(modelo())
    cat("R² =", round(s$r.squared, 4), "\n")
    cat("R² ajustado =", round(s$adj.r.squared, 4), "\n")
    cat("F-statistic p-value:", format.pval(pf(s$fstatistic[1],
                                                s$fstatistic[2],
                                                s$fstatistic[3],
                                                lower.tail = FALSE)), "\n\n")
    cat("Coeficientes:\n")
    print(round(coef(s)[, c(1, 4)], 4))
  })

  output$plot_residuos <- renderPlotly({
    df_res <- data.frame(
      fitted   = fitted(modelo()),
      residuos = residuals(modelo())
    )
    p <- ggplot(df_res, aes(x = fitted, y = residuos)) +
      geom_point(alpha = 0.4, color = "#8e44ad", size = 1.5) +
      geom_hline(yintercept = 0, color = "#e74c3c", linetype = "dashed") +
      geom_smooth(se = FALSE, color = "#3498db", size = 1) +
      labs(title = "Gráfico de residuos vs valores ajustados",
           x = "Valores ajustados", y = "Residuos") +
      theme_minimal(base_size = 12) +
      theme(plot.title = element_text(size = 13, face = "bold"))
    ggplotly(p)
  })

  # ===== PESTAÑA 4: TABLA =====

  output$tabla_datos <- renderDT({
    datos_cont() %>%
      mutate(
        pop       = formatC(pop, format = "d", big.mark = ","),
        gdpPercap = paste0("$", formatC(round(gdpPercap, 2),
                                        format = "f", digits = 2, big.mark = ",")),
        lifeExp   = round(lifeExp, 2)
      ) %>%
      rename(
        País        = country,
        Continente  = continent,
        Año         = year,
        `Esp. vida` = lifeExp,
        Población   = pop,
        `PIB/cáp`   = gdpPercap
      ) %>%
      datatable(
        filter    = "top",
        options   = list(pageLength = 15, scrollX = TRUE),
        class     = "stripe hover compact",
        rownames  = FALSE
      )
  })

} # fin server

# ---- 5. EJECUTAR APP ----
shinyApp(ui = ui, server = server)
