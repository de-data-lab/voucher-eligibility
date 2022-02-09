# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighbohood is Doing"),
    #leafletOutput("advocmap"),
    tags$div(class = "advoc-container",
             uiOutput("GEOID_selector")),
    tags$div(class = "advoc-table",
             tableOutput("advoc_table")),
    tags$div(class = "advoc-table",
             downloadButton("downloadData", "Download"))
)
