# Map module
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)
library(leaflet.extras)
source("R/map_utils.R")


map_UI <- function(id) {
    leafletOutput(NS(id, "explore_map"), height = "100vh")
}

map_server <- function(id, selected_GEOIDs, geo_data) {
    moduleServer(id, function(input, output, session) {
        
        # Output a leaflet map
        explore_map <- geo_data %>%
            leaflet(options = leafletOptions(zoomControl = FALSE,
                                             attributionControl = FALSE,
                                             scrollWheelZoom = FALSE,
                                             gestureHandling = TRUE)) %>%
            addTiles() %>%
            addPolygons(fillColor = "#bdc9e1",
                        stroke = TRUE, fillOpacity = 0.5, smoothFactor = 0.5,
                        color = "#66C2A5", opacity = 1, weight=2,
                        highlight = highlightOptions(fillOpacity = 0.8,
                                                     color = "#FC8D62",
                                                     weight = 2,
                                                     bringToFront=TRUE),
                        label = ~census_tract_label, layerId = ~GEOID) %>%
            # Position the zoom tools on top right
            htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this) }")
        
        # Render the explore map
        output$explore_map <- renderLeaflet({ explore_map })
        
        # If the map is clicked, update the reactive value
        observe({
            # Get the clicked tract
            clicked_tract <- input[[paste0(id, "_map_shape_click")]]$id
            # Get current GEOIDs
            cur_selected_GEOIDs <- selected_GEOIDs()
            
            # Clicked tract and selected GEOIDs can both be null
            # and can't be passed to the if clause
            
            # If the clicked tract is not in the selected tracts, 
            # highlight it
            if(!(clicked_tract %in% cur_selected_GEOIDs)) {
                # Update the reactive value 
                selected_GEOIDs(union(cur_selected_GEOIDs, clicked_tract))
            }
            
            # If the clicked tract is in the selected tracts,
            # remove the highlight
            if(clicked_tract %in% cur_selected_GEOIDs){
                # Update the reactive value, `setdiff` to remove the clicked tract
                selected_GEOIDs(setdiff(cur_selected_GEOIDs, clicked_tract))
            }
            
        }) %>%
            # Only observe with a click event (to avoid getting NULL on click)
            bindEvent(input[[paste0(id, "_map_shape_click")]]$id)
        
        # Update the map according to the updated GEOID
        observe({
            # Redraw map with the new GEOIDs
            if(length(selected_GEOIDs()) > 0){
                map_highlight(id = NS(id, "explore_map"),
                              GEOIDs = selected_GEOIDs(),
                              geo_data)
            }
            
            # Get a list of GOIDs to remove highlight
            unselected_GEOIDs <- geo_data$GEOID[!geo_data$GEOID %in% selected_GEOIDs()]
            map_remove_highlight(id = NS(id, "explore_map"),
                                 GEOIDs = unselected_GEOIDs,
                                 geo_data)
            
        }) %>%
            bindEvent(selected_GEOIDs(), ignoreNULL = FALSE)
        
    })
}
