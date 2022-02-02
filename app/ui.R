library(shiny)
library(leaflet)
library(plotly)

# Load tab-panels
source("home_panel.r")
source("advocates_panel.r")

navbarPage(
    "Housing Choice Voucher in Delaware",
    header = tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    home_panel, # Add a tab panel for home
    advocates_panel,
    tabPanel("Details",
             leafletOutput("map"),
             tags$h1("Methodology"),
             "We defined households potentially eligible for housing vouchers by 
             calculating renter households paying 30% or more income on rent. We
             also excluded households with gross income exceeding $100,000."
    ),
    footer = tags$div(class = "footer",
                      includeHTML("footer.html"))
)

