# A helper function to change the leaflet map given the id
map_update <- function(id, data, to = "highlight"){
    if(to == "highlight"){
        fill_color <- "#FC8D62"
        fillOpacity <- 0.8
    }
    if(to == "remove"){
        fill_color <- "#bdc9e1"
        fillOpacity <- 0.5
    }
    # Update the map
    leaflet::leafletProxy(id) %>%
        leaflet::addTiles() %>%
        leaflet::addPolygons(data = data,
                    fillColor = fill_color,
                    color = "#66C2A5",
                    weight = 2,
                    opacity = 1,
                    fillOpacity = 0.5,
                    smoothFactor = 0.5,
                    stroke = TRUE,
                    highlight = leaflet::highlightOptions(fillOpacity = fillOpacity,
                                                 color = "#FC8D62",
                                                 weight = 2,
                                                 bringToFront=TRUE),
                    label = ~census_tract_label, layerId = ~GEOID)
}

# Highlight the GEOIDs in the map
map_highlight <- function(id, GEOIDs, geo_data){
    fill_color <- "#FC8D62"
    fillOpacity <- 0.8
    # Get census tracts to be highlighted
    new_data <- geo_data %>%
        filter(GEOID %in% GEOIDs)

    # Calculate the coordinate to fly to with highlight
    fly_to_centroid <- new_data %>% 
        summarise(lon = mean(lon, na.rm = TRUE),
                  lat = mean(lat, na.rm = TRUE))

    # Update the map
    map_update(id, new_data, to = "highlight") %>%
        # Fly to the centroid of the selection
        flyTo(lng = fly_to_centroid$lon,
              lat = fly_to_centroid$lat,
              zoom = 11)
}

# Remove highlights of the GEOIDs in the map
map_remove_highlight <- function(id, GEOIDs, geo_data){
    fill_color <- "#bdc9e1"
    fillOpacity <- 0.5
    # Get census tracts to be highlighted
    new_data <- geo_data %>%
        filter(GEOID %in% GEOIDs)
    # Update the map
    map_update(id, new_data, to = "remove")
}
