# Handle update on map
library(leaflet)
update_map <- function(new_data, to_state){
    
    if(to_state == "deselect"){
        fill_color <- "#bdc9e1"
        fillOpacity <- 0.5
    }
    if(to_state == "select"){
        fill_color <- "#b30000"
        fillOpacity <- 0.8
    }
    leafletProxy("advocmap") %>%
        addTiles() %>%
        addPolygons(data = new_data,
                    fillColor = fill_color,
                    color = "#2b8cbe",
                    weight = 2,
                    opacity = 1,
                    fillOpacity = 0.5,
                    smoothFactor = 0.5,
                    stroke = TRUE,
                    highlight = highlightOptions(fillOpacity = 0.8,
                                                 color = "#b30000",
                                                 weight = 2,
                                                 bringToFront=TRUE),
                    label = ~census_tract_label, layerId = ~GEOID)
    

}
