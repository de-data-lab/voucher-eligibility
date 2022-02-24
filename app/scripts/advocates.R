library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(leaflet)
library(tigris)


shape <- tracts(state='10') %>% select(GEOID, NAMELSAD, NAME)
lat <- 39.1824#39.5393
lng <- -75.2


# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
  st_drop_geometry()

advoc_table <- geo_data_nogeometry %>% 
  #mutate(reported_labels=ifelse(number_reported==-4,"Less than 10 Households","NA")) %>%
  #mutate(number_reported =replace(number_reported, number_reported<0, 0) ) %>%
  rowwise() %>%
  #mutate(above30 = sum(rent_30E, rent_35E, rent_40E,rent_50E),
  #       above50=rent_50E) %>%
  filter(popTotEE>0) %>%
  mutate(above30 = eligible_renters,
         above50 = sum(rent_50_10kE,rent_50_20kE,rent_50_35kE,rent_50_50kE,rent_50_75kE)) %>%
  group_by(GEOID) %>%
  summarize(tot_hh=sum(tot_hhE),reported_HUD=sum(number_reported),rent_above30=sum(above30),rent_above50=sum(above50)) %>%
  mutate(prop_above30 = (rent_above30/tot_hh)*100,
         prop_above50 = (rent_above50/tot_hh)*100,
         prop_reported_HUD = (reported_HUD/tot_hh)*100) %>%
  mutate_at(vars(prop_above30),~ round(., 2)) %>%
  mutate_at(vars(prop_above50),~ round(., 2)) %>%
  mutate_at(vars(prop_reported_HUD),~ round(., 2)) %>%
  mutate_at(vars(reported_HUD),as.integer) %>%
  mutate_at(vars(rent_above30),as.integer) %>%
  mutate_at(vars(rent_above50),as.integer) %>%
  replace(is.na(.), 0) %>%
  dplyr::rename(
    '% Receiving assisstance'=prop_reported_HUD,
    '% Spending 30%+ of income on rent'=prop_above30,
    '% Spending 50%+ of income on rent'=prop_above50,
    '# Receiving assisstance'=reported_HUD,
    '# Spending 30%+ of income on rent'=rent_above30,
    '# Spending 50%+ of income on rent'=rent_above50,
  ) 

  
advoc_table <- inner_join(advoc_table,shape,by='GEOID') %>%   
  mutate_at(vars(NAME),as.double) %>%
  arrange(NAME)


advoc_map <- shape %>% filter(GEOID %in% advoc_table$GEOID) %>%
  leaflet(height="250%", width="100%") %>%
  setView(lng, lat, zoom = 8.0) %>%
  addTiles() %>%   #not including one, sets the general maps version
  
  addPolygons(fillColor = "#bdc9e1",
              stroke = TRUE, fillOpacity = 0.5, smoothFactor = 0.5,
              color = "#2b8cbe",opacity = 1,weight=2,
              highlight=highlightOptions(fillOpacity = 0.8,
                                         color = "#b30000",
                                         weight = 2,
                                         bringToFront=TRUE),
              label= ~NAMELSAD, layerId = ~NAMELSAD)
