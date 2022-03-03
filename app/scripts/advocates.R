library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)
library(leaflet.extras)



# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined 




advoc_table <- geo_data %>% 
    rowwise() %>%
    filter(popTotEE>0) %>%
    mutate(above30 = eligible_renters,
           above50 = sum(rent_50_10kE, rent_50_20kE, rent_50_35kE, rent_50_50kE, rent_50_75kE)) %>%
    transmute(GEOID = GEOID,
              tract,
              census_tract_label,
              geometry,
              tot_hh = sum(tot_hhE),
              reported_HUD = sum(number_reported),
              rent_above30 = sum(above30),
              rent_above50 = sum(above50)) %>%
    mutate(prop_above30 = (rent_above30/tot_hh)*100,
         prop_above50 = (rent_above50/tot_hh)*100,
         prop_reported_HUD = (reported_HUD/tot_hh)*100) %>%
  mutate_at(vars(prop_above30, 
                 prop_above50,
                 prop_reported_HUD,
                 reported_HUD),~ round(., 2)) %>%
  mutate_at(vars(reported_HUD,
                 rent_above30,
                 rent_above50), as.integer) %>%
  replace(is.na(.), 0) %>%
  dplyr::rename(
    '% Receiving assisstance'=prop_reported_HUD,
    '% Spending 30%+ of income on rent'=prop_above30,
    '% Spending 50%+ of income on rent'=prop_above50,
    '# Receiving assisstance'=reported_HUD,
    '# Spending 30%+ of income on rent'=rent_above30,
    '# Spending 50%+ of income on rent'=rent_above50,
  ) 


for (row in 1:nrow(advoc_table)) {
  #print(row)
  geo<-unlist(advoc_table[row,"geometry"],use.names = FALSE)
  advoc_table[row,"latt"]=geo[length(geo)]
  advoc_table[row,"long"]=geo[1]
}

lat <- 39.1824#39.1824#39.5393
lng <- -75.4#-75.2



geo_data <- left_join(geo_data,
                      advoc_table %>% select('GEOID','% Receiving assisstance',
                                             '% Spending 30%+ of income on rent',
                                             '% Spending 50%+ of income on rent'),
                      by="GEOID"
                      )

# popUp <- with(geo_data,paste0("<br><b>Census Tract:</b>",geo_data$tract,
#                               "<br><b>% Household receiving Vouchers:</b>",geo_data$'% Receiving assisstance',
#                               "<br><b>% Household spending 30%+ income on rent:</b> ", geo_data$'% Spending 30%+ of income on rent',
#                               "<br><b>% Household spending 50%+ income on rent:</b> ", geo_data$'% Spending 50%+ of income on rent'
#                               
# ))

advoc_map <- geo_data %>%
    leaflet(options = 
              leafletOptions(zoomControl = F,attributionControl = FALSE, 
                             scrollWheelZoom = F,gestureHandling = T)) %>%
    setView(lng, lat, zoom = 9.4) %>%
    addTiles() %>% #not including one, sets the general maps version
    addPolygons(fillColor = "#bdc9e1",
                stroke = TRUE, fillOpacity = 0.5, smoothFactor = 0.5,
                #popup = popUp,
                color = "#2b8cbe", opacity = 1, weight=2,
                highlight=highlightOptions(fillOpacity = 0.8,
                                           color = "#b30000",
                                           weight = 2,
                                           bringToFront=TRUE),
                label = ~census_tract_label, layerId = ~GEOID) %>%
htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }")

#label = ~census_tract_label,
