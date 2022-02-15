# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighbohood is Doing"),
    tags$div(class = "address-input-container",
             searchInput("address", label = NULL, placeholder = "Enter your address",
                         btnSearch = icon("search")),
             textOutput("current_GEOID")),
    leafletOutput("advocmap"),
    tags$div(class = "advoc-table",
             tableOutput("advoc_table")),
    tags$div(class = "advoc-table",
             downloadButton("downloadData", "Download"))
)
