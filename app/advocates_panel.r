# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighbohood is Doing"),
    tags$div(class = "center-container",
             uiOutput("GEOID_selector")),
    tags$div(class = "main-point",
             "In the selected X census tracts, only XX% of the families
             needing Housing Vouche Voucher are receiving it."),
    tags$div(class = "comment",
             "(*Add a pie chart for the overview? receiving vs not receiving)"),
    tags$div(class = "comment",
             "(*Add the table showing reported & eligible households)")
)
