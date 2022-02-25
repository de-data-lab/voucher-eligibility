# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "Explore Your Neighborhood",
    tags$div(class = "main-point",
             "Find Out How Your Neighborhood is Doing"),
    tags$div(class = "sub-point",
             "Find out what percentage of households in your neighbourhood
             are receiving Housing Choice Voucher and
              what percentage of households are spending
             more than 30% and 50% of their income on rent"),
    tags$div(class = "address-input-container",
             searchInput("address", label = NULL, placeholder = "Enter your address",
                         btnSearch = icon("search")),
             tags$div(class = "address-message",
                      textOutput("address_message"))
             ),
    leafletOutput("advocmap"),
    tags$div(class = "advoc-container",
             tags$div(class = "advoc-table-container",
                      tags$div(class = "advoc-table",
                               tableOutput("advoc_table")
                      ),
                      tableOutput("table_desc"),
                      tags$div(class = "table-footnote",
                               downloadButton("downloadData", "Download")),
                      tags$div(class = "down-footnote","(Dowloads data from above table)"),
                      tags$div(class = "table-footnote",
                               "The number of households appears as 10 when there are 10 or less 
             households in a given cell.",
                               tags$br(),
                               downloadLink("downloadAll", "Download All Data"))
             ),
             tags$div(class = "bar-graph",
                      plotlyOutput("prop_census"),
                      radioGroupButtons("selectedCensusProp", 
                                        label = "Focusing on families with rent spending:",
                                        choices = c("30%+ of income" = "30",
                                                    "50%+ of income" = "50"),
                                        selected='30')
             )
    )
    
)

