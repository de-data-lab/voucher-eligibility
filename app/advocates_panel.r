# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighborhood is Doing"),
    tags$div(class = "address-input-container",
             searchInput("address", label = NULL, placeholder = "Enter your address",
                         btnSearch = icon("search")),
             textOutput("current_GEOID")),
    leafletOutput("advocmap"),
    tags$div(class = "advoc-table",
             tableOutput("advoc_table")),
    tags$div(class = "advoc-table",
             downloadButton("downloadData", "Download"),
             downloadButton("downloadAll", "Download All")),
    tags$div(class = "table-footnote",
             "The number of households appears as 10 when there are 10 or less 
             households in a given cell. 
             NA indicates that there are no households participating in
             Section 8 for the given census tract, according to HUD.")
)
