library(shiny)
library(leaflet)
library(plotly)

# Load tab-panels
source("R/home_panel.r")
source("R/explore_panel.R")
source("R/methods_panel.R")

navbarPage(
    id = "main_page",
    title = "Housing Choice Voucher in Delaware",
    header = tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    home_panel(), # Add a tab panel for home
    explore_panel,
    methods_panel,
    footer = div(class = "footer",
                 includeHTML("footer.html"),
                 tags$script(src = "show_logo.js"))
)

