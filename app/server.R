#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(here)
library(tidyverse)
library(plotly)
library(sf)

geo_data <- read_rds("acs_hud_de_geojoined.rds")

# Labels
popUp <- with(geo_data,
              paste0("<br><b>GEOID:</b> ", geo_data$GEOID,
                     "<br><b>Census Tract:</b> ", geo_data$tract,
                     "<br><b>Serviced Renters:</b> ", geo_data$number_reported,
                     "<br><b>Eligible Renters:</b> ", geo_data$eligible_renters
              ))
cols <- colorNumeric(
    palette = "inferno",
    domain = geo_data$prop_serviced, reverse = TRUE)

default_lat <- 39.1824
default_lng <- -75.2

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$map <- renderLeaflet({
        geo_data %>% 
            leaflet() %>%
            addTiles(providers$CartoDB.Positron) %>%
            setView(default_lng, default_lat, zoom = 8.0) %>%
            addPolygons(fillColor = ~cols(geo_data$prop_serviced),
                        color = "#B2AEAE",
                        fillOpacity = 1,
                        weight = 1,
                        smoothFactor = 0.4,
                        popup = popUp
            ) %>%
            addLegend(pal = cols,
                      values = geo_data$prop_serviced,
                      position = "bottomright",
                      title = paste("Proportion of <br> Serviced Renters",sep=" "))
        

    })
    
    output$mainplot <- renderPlotly({
        geo_long <- geo_data %>%
            st_drop_geometry() %>% 
            mutate(number_not_using = eligible_renters - number_reported) %>%
            select(GEOID, COUNTYFP, number_not_using, number_reported) %>%
            pivot_longer(cols = c("number_not_using", "number_reported")) %>%
            mutate(labels = case_when(name == "number_not_using" ~ "Not Receiving Voucher",
                                      name == "number_reported" ~ "Receiving Voucher"))

        statewide <- geo_long %>%
            group_by(labels) %>%
            summarise(counts = sum(value, na.rm = T))
        
        statewide %>%
            plot_ly(labels = ~labels, values = ~counts,
                    type = 'pie',
                    textinfo = 'label+percent',
                    insidetextorientation = 'horizontal',
                    showlegend = FALSE) %>%
            layout(title = list(text = "Renters Eligible for Housing Choice Voucher"),
                   margin = list(t = 50))
                   
        
        
    })

})
