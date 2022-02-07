# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighbohood is Doing"),
    leafletOutput("advocmap"),
    tags$div(class = "center-container",
             uiOutput("GEOID_selector")),
    tableOutput("advoc_table")
)
