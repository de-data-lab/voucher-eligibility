# Advocates Tab Panel
library(shinyWidgets)

advocates_panel <- tabPanel(
    title = "Explore Your Neighborhood",
    tags$div(
        class = "explore-page-container",
        tags$div(class = "map-container",
                 tags$div(
                     class = "map-header-container",
                     tags$div(
                         class = "clear-all-button", 
                         actionButton("clear", "Clear All"))
                 ),
                 leafletOutput("advocmap",
                               height = "100vh"
                 ),
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
        tags$div(class = "explore-contents-container", 
                 tags$div(class = "explore-title-container",
                          tags$div(class = "main-point bold",
                                   "How is your neighborhood doing?"),
                          tags$div(class = "explore-subtitle",
                                   icon("mouse-pointer"),
                                   "Select census tracts on the map",
                                   tags$br(),
                                   "or",
                                   tags$br(),
                                   icon("edit"),
                                   "Look up a census tract using your address"),
                          tags$div(class = "address-input-container",
                                   searchInput("address", label = NULL, placeholder = "Street Address",
                                               btnSearch = icon("search")),
                                   tags$div(class = "address-message",
                                            textOutput("address_message")
                                   )
                          )
                 ),
                 tags$div(class = "explore-bar-container",
                          tags$div(class = "bar-graph",
                                   "% of Households receiving vouchers and spending 30%+ income and 50%+ income on rent",
                                   plotlyOutput("table_desc_plot")
                          ),
                          htmlOutput("table_desc")
                 ),
                 tags$div(class = "bar-graph",
                          #textOutput("bar_title"),             
                          selectInput("selectedCensusProp", 
                                           label = NULL,
                                           choices = c("Rent burdened - % Household spending 30%+ income on rent" = "30",
                                                       "Severely rent-burdened % Household spending 50%+ income on rent" = "50"),
                                           selected = "30",
                                           width = 800),
                          "The plot below shows % Households for all Census Tract",
                          plotlyOutput("prop_census")
                 ),
                 tags$div(class = "advoc-table-container",
                          tags$div(class = "advoc-table",
                                   tableOutput("advoc_table")
                          ),
                          tags$div(class = "table-footnote",
                                   downloadButton("downloadData", "Download")),
                          tags$div(class = "down-footnote","(Dowloads data from above table)"),
                          tags$div(class = "table-footnote",
                                   "The number of households appears as 10 when there are 10 or less 
             households in a given cell.",
                                   tags$br(),
                                   downloadLink("downloadAll", "Download All Data"))
                 )
        )
    )
)

