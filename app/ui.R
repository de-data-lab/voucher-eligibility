library(shiny)
library(leaflet)
library(plotly)

# Load tab-panels
source("home_panel.r")
source("advocates_panel.r")
source("counties_panel.R")
source("methods_panel.R")

navbarPage(
    "Housing Choice Voucher in Delaware",
    header = tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    home_panel, # Add a tab panel for home
    counties_panel,
    advocates_panel,
    methods_panel,
    footer = tags$div(class = "footer",
                      includeHTML("footer.html"))
)

