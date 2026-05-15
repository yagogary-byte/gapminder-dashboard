# 🌍 Dashboard Gapminder — Desarrollo Humano Mundial

**Producto Académico Colaborativo · Curso: Programación en R**

[![R](https://img.shields.io/badge/R-≥4.0-276DC3?logo=r)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-1.7+-blue)](https://shiny.rstudio.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🔗 Links

| Recurso | URL |
|:--------|:----|
| 🚀 Dashboard en línea |https://oscar127.shinyapps.io/HerramientasInforma/
| 📄 Informe RPubs | https://rpubs.com/usuario/gapminder-pac |
| 📊 Dataset | [Paquete {gapminder}](https://CRAN.R-project.org/package=gapminder) |

---

## 📋 Descripción

Dashboard interactivo desarrollado en R Shiny que permite explorar los datos de
**Gapminder** (142 países, 1952–2007) a través de:

- 📈 Tendencias temporales por país (esperanza de vida, PIB, población)
- 🗺️ Comparación entre continentes con boxplots y gráfico de burbuja
- 🧮 Modelo de regresión lineal múltiple interactivo
- 📋 Tabla de datos filtrable y ordenable

---

## 🛠️ Instalación y uso local

### 1. Clonar el repositorio

```bash
git clone https://github.com/usuario/gapminder-dashboard.git
cd gapminder-dashboard
```

### 2. Instalar paquetes de R

```r
install.packages(c("shiny", "ggplot2", "dplyr", "gapminder",
                   "plotly", "DT", "scales"))
```

### 3. Ejecutar la aplicación

```r
shiny::runApp("app.R")
```

---

## 📁 Estructura del proyecto

```
gapminder-dashboard/
├── app.R                      # Aplicación Shiny completa (UI + Server)
├── informe_gapminder.Rmd      # Informe en R Markdown → RPubs
├── presentacion_gapminder.Rmd # Diapositivas ioslides para presentación oral
├── README.md                  # Este archivo
└── LICENSE
```

---

## 📦 Paquetes utilizados

| Paquete | Función |
|:--------|:--------|
| `shiny` | Framework de aplicación web reactiva |
| `ggplot2` | Visualización estática de datos |
| `plotly` | Gráficos interactivos (zoom, hover) |
| `dplyr` | Manipulación y filtrado de datos |
| `gapminder` | Dataset de desarrollo humano |
| `DT` | Tabla interactiva con búsqueda y paginación |
| `scales` | Formateo de ejes (comas, porcentajes) |

---

## 👥 Equipo

- Estudiante 1
- Estudiante 2
- Estudiante 3

---

## 📚 Referencias

- Bryan, J. (2017). *gapminder*. CRAN.
- Wickham, H. (2016). *ggplot2*. Springer.
- Heiss, F. (2020). *Using R for Introductory Econometrics* (2nd ed.).

---

*MIT License · 2024*
