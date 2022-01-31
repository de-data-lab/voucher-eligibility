library(shiny)
library(leaflet)
library(plotly)
library(here)

# Load tab-panels
source(here("app/home_panel.r"))
source(here("app/advocates_panel.r"))

navbarPage(
    "Housing Choice Voucher in Delaware",
    header = tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    home_panel, # Add a tab panel for home
    advocates_panel,
    tabPanel("Details",
             leafletOutput("map"),
             "We defined renters potentially eligible for housing vouchers by calculating renter households paying 30% or more income on rent."
    ),
    footer = tags$div(class = "footer",
                      includeHTML("footer.html"))
)

