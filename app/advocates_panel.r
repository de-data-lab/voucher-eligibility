# Advocates Tab Panel
advocates_panel <- tabPanel(
    "For Advocates",
    tags$div(class = "main-point",
             "Find Out How Your Neighbohood is Doing"),
    tags$div(class = "center-container",
             textInput("geoid", "GEOID")),
    tags$div(class = "main-point",
             "(Vizualization on per census tract)")
)
