# Explore Tab Panel
library(shinyWidgets)
source("R/map.R")
source("R/rank_plot.R")

explore_panel <- tabPanel(
    title = "Explore Your Neighborhood",
    fluidRow(
        class = "explore-page-container",
        tags$div(class = "map-container",
                 tags$div(
                     class = "map-header-container",
                     tags$div(
                         class = "clear-all-button", 
                         actionButton("clear", "Clear All"))
                 ),
                 map_UI("explore"),
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
                                   tags$div(class = "explore-bar-title",
                                            "Percent of families that are:"),
                                   plotlyOutput("table_desc_plot")
                          )

                 ),
                 tags$div(class = "bar-footnote-container",
                          tags$span(class = "tooltip-span",
                                    icon(name = "question-circle"), "What do \"rent-burdnened\" and \"severely rent-burdened\" mean?",
                                    tags$span(class = "tooltip-text",
                                              "Families spending more than 30% of their income on
                                              rent are considered \"rent-burdened\". 
                                              If they are spending more than 50%, they are considered
                                              \"severely rent-burdened\"."))
                 ),
                 rank_plot_UI("rank_plot"),
                 tags$div(class = "bar-graph",
                          plotlyOutput("prop_census")
                 ),
                 tags$div(class = "hbar-description-container",
                          htmlOutput("table_desc")
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
                 ),
                 includeHTML("CTA.html")
        )
    )
)

