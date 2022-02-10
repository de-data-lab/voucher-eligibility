library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)
library(tigris)


shape <- tracts(state='10') %>% select(GEOID, NAMELSAD, NAME)
# lat <- 39.1824#39.5393
# lng <- -75.2
# advoc_map <- shape %>%
#   leaflet() %>%
#   addTiles(providers$CartoDB.Positron) %>%   #not including one, sets the general maps version
#   setView(lng, lat, zoom = 8.0) %>%
#   addPolygons(fillColor = "blue",
#               highlight=highlightOptions(weight=5,
#                                          color='red',
#                                          fillOpacity = 0.7,
#                                          bringToFront=TRUE),
#               label= ~NAMELSAD, layerId = ~GEOID)



# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
  st_drop_geometry()

advoc_table <- geo_data_nogeometry %>% 
  #mutate(reported_labels=ifelse(number_reported==-4,"Less than 10 Households","NA")) %>%
  #mutate(number_reported =replace(number_reported, number_reported<0, 0) ) %>%
  rowwise() %>%
  mutate(above30 = sum(rent_30E, rent_35E, rent_40E,rent_50E),
         above50=rent_50E) %>%
  group_by(GEOID) %>%
  summarize(reported_HUD=sum(number_reported),rent_above30=sum(above30),rent_above50=sum(above50)) %>%
  mutate_at(vars(reported_HUD),as.integer) %>%
  mutate_at(vars(rent_above30),as.integer) %>%
  mutate_at(vars(rent_above50),as.integer) %>%
  dplyr::rename(
    '# Receiving assisstance'=reported_HUD,
    '# Spending 30%+ of income on rent'=rent_above30,
    '# Spending 50%+ of income on rent'=rent_above50,
  ) 
  
advoc_table <- inner_join(advoc_table,shape,by='GEOID')   %>% 
  mutate(NAME_numeric=as.numeric(NAME)) %>% 
  arrange(NAME_numeric)
