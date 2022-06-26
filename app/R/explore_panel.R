# Explore Tab Panel
library(shinyWidgets)
source("R/map.R")
source("R/rank_plot.R")
source("R/compare_to_de_plot.R")
source("R/address_search.R")
source("R/explore_table.R")

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
                address_search_UI("address_search"),
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
                # Explore table UI module 
                explore_table_UI("explore_table")
            ),
            includeHTML("CTA.html")
        )
    )
)

