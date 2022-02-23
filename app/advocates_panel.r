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
    tags$div(class = "advoc-container",
        tags$div(class = "advoc-table",
            tags$div(class = "div1",
                     tableOutput("advoc_table"),
                     downloadButton("downloadData", "Download"),
                     downloadButton("downloadAll", "Download All"),
                     tags$div(class = "table-footnote",
                              "The number of households appears as 10 when there are 10 or less 
             households in a given cell."))
            ),
        tags$div(class = "bar-graph",
                 tags$div(class = "div1",
                            plotlyOutput("prop_census"),
                     radioGroupButtons("selectedCensusProp", 
                                       label = "Focusing on families with rent spending:",
                                       choices = c("30%+ of income" = "30",
                                                   "50%+ of income" = "50"),
                                       selected='30')))
        )
    
)
