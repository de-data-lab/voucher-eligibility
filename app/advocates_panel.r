# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "Explore Your Neighborhood",
    tags$div(class = "explore-title-container",
             tags$div(class = "main-point bold",
                      "How is your neighborhood doing?"),
             tags$div(class = "sub-point",
                      "Find out what percentage of households in your neighbourhood
             are receiving Housing Choice Voucher and
              what percentage of households are spending
             more than 30% and 50% of their income on rent")
             ),
    tags$div(class = "advoc-container",
        tags$div(class = "advoc-table-container",
                 tags$div(
                     class = "map-header-container",
                          tags$div(class = "address-input-container",
                                   searchInput("address", label = NULL, placeholder = "Enter your address",
                                               btnSearch = icon("search")),
                                   tags$div(class = "address-message",
                                            textOutput("address_message")
                                   )
                          ),
                     tags$div(
                         class = "clear-all-button", 
                         actionButton("clear", "Clear All"))
                 ),
                 leafletOutput("advocmap",height="110vh",width="60vh"),
                 tags$script("
                    $(document).ready(function() {    
                      setTimeout(function() {
                
                        var map = $('#advocmap').data('leaflet-map');            
                        function disableZoom(e) {map.scrollWheelZoom.disable();}
                
                        $(document).on('mousemove', '*', disableZoom);
                
                        map.on('click', function() {
                          $(document).off('mousemove', '*', disableZoom);
                          map.scrollWheelZoom.enable();
                        });
                      }, 100);
                    })
                  ")),
        tags$div(class = "bar-graph","% of Households receiving vouchers and spending 30%+ income and 50%+ income on rent",
                 plotlyOutput("table_desc_plot"),tableOutput("table_desc"))
             ),
    tags$div(class = "advoc-container",
             tags$div(class = "advoc-table-container",
                      tags$div(class = "advoc-table",
                               tableOutput("advoc_table")
                      ),
                      #tableOutput("table_desc"),
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

