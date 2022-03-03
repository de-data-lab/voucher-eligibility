# Handle update on map
library(leaflet)
update_map <- function(new_data, to_state,addr,latt,long){
    
    if(to_state == "deselect"){
        fill_color <- "#bdc9e1"
        fillOpacity <- 0.5
    }
    if(to_state == "select"){
        fill_color <- "#b30000"
        fillOpacity <- 0.8
    }
    # popUp <- with(new_data,paste0("<b>Census Tract:</b>",new_data$tract,
    #                               "<br><b>% Household receiving Vouchers:</b>",new_data$'% Receiving assisstance',
    #                               "<br><b>% Household spending 30%+ income on rent:</b> ", new_data$'% Spending 30%+ of income on rent',
    #                               "<br><b>% Household spending 50%+ income on rent:</b> ", new_data$'% Spending 50%+ of income on rent'
    #                               
    # ))
    
    if (addr){

        leafletProxy("advocmap") %>%
            addTiles() %>%
            setView(lng=long, lat=latt, zoom = 10) %>%
            addPolygons(data = new_data,
                        fillColor = fill_color,
                        color = "#2b8cbe",
                        weight = 2,
                        opacity = 1,
                        fillOpacity = 0.5,
                        smoothFactor = 0.5,
                        #popup = popUp,
                        stroke = TRUE,
                        highlight = highlightOptions(fillOpacity = 0.8,
                                                     color = "#b30000",
                                                     weight = 2,
                                                     bringToFront=TRUE),
                        label = ~census_tract_label, layerId = ~GEOID)
    }
    else{
        leafletProxy("advocmap") %>%
            addTiles() %>%
            addPolygons(data = new_data,
                        fillColor = fill_color,
                        color = "#2b8cbe",
                        weight = 2,
                        opacity = 1,
                        fillOpacity = 0.5,
                        smoothFactor = 0.5,
                        #popup = popUp,
                        stroke = TRUE,
                        highlight = highlightOptions(fillOpacity = 0.8,
                                                     color = "#b30000",
                                                     weight = 2,
                                                     bringToFront=TRUE),
                        label = ~census_tract_label, layerId = ~GEOID)
        
    }
    

}
