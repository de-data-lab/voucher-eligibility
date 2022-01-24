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

geo_data <- read_rds(here("data/processed/acs_hud_de_geojoined.rds"))

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
            mutate(number_not_using = eligible_renters - number_reported) %>%
            select(GEOID, COUNTYFP, number_not_using, number_reported) %>%
            pivot_longer(cols = c("number_not_using", "number_reported")) %>%
            mutate(labels = case_when(name == "number_not_using" ~ "Not receiving Section 8",
                                      name == "number_reported" ~ "Receiving Section 8"))

        # geo_long %>%
        #     ggplot(aes(x = "", y = value, fill = name, color = name)) +
        #     geom_bar(stat = "identity") +
        #     coord_polar("y", start = -2)
        geo_long %>% 
            plot_ly(labels = ~labels, values = ~value, type = 'pie') %>%
            layout(title = "Renters Receiving Section 8",
                   mode = "hide",
                   xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))
        
        
    })

})
