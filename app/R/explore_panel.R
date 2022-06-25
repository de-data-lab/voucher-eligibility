# Explore Tab Panel
library(shinyWidgets)
source("R/map.R")
source("R/rank_plot.R")
source("R/compare_to_de_plot.R")

explore_panel <- tabPanel(
    title = "Explore Your Neighborhood",
    fluidRow(
        class = "explore-page-container",
        div(class = "map-container",
            div(class = "map-header-container",
                div(class = "clear-all-button", 
                    actionButton("clear", "Clear All"))),
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
        div(class = "explore-contents-container", 
            div(class = "explore-title-container",
                div(class = "main-point bold",
                    "How is your neighborhood doing?"),
                div(class = "explore-subtitle",
                    icon("mouse-pointer"),
                    "Select census tracts on the map",
                    br(),
                    "or",
                    br(),
                    icon("edit"),
                    "Look up a census tract using your address"),
                div(class = "address-input-container",
                    searchInput("address", label = NULL, placeholder = "Street Address",
                                btnSearch = icon("search")),
                    div(class = "address-message",
                        textOutput("address_message")
                    )
                )
            ),
            compare_to_de_plot_UI("compare_to_de"),
            div(class = "bar-footnote-container",
                tags$span(class = "tooltip-span",
                          icon(name = "question-circle"), "What do \"rent-burdnened\" and \"severely rent-burdened\" mean?",
                          tags$span(class = "tooltip-text",
                                    "Families spending more than 30% of their income on
                                              rent are considered \"rent-burdened\". 
                                              If they are spending more than 50%, they are considered
                                              \"severely rent-burdened\"."))
            ),
            rank_plot_UI("rank_plot"),
            div(class = "advoc-table-container",
                div(class = "advoc-table",
                    tableOutput("advoc_table")
                ),
                div(class = "table-footnote",
                    downloadButton("downloadData", "Download")),
                div(class = "down-footnote","(Dowloads data from above table)"),
                div(class = "table-footnote",
                    "The number of households appears as 10 when there are 10 or less 
             households in a given cell.",
                    br(),
                    downloadLink("downloadAll", "Download All Data"))
            ),
            includeHTML("CTA.html")
        )
    )
)

