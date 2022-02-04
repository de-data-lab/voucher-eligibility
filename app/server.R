library(shiny)
library(tidyverse)
library(plotly)
library(sf)

# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
    st_drop_geometry()

# Reshape the dataset into the long format for summarizing 
geo_long <- geo_data_nogeometry %>%
    mutate(number_not_using = eligible_renters - number_reported) %>%
    select(GEOID, COUNTYFP, number_not_using, number_reported) %>%
    pivot_longer(cols = c("number_not_using", "number_reported")) %>%
    mutate(labels = case_when(name == "number_not_using" ~ "Not Receiving Voucher",
                              name == "number_reported" ~ "Receiving Voucher"))
# Get the summarized data for rendering percentages
de_summary <- geo_long %>% 
    group_by(labels) %>%
    summarise(counts = sum(value, na.rm = T)) %>%
    mutate(percent = 100 * counts / sum(counts))
# Get the vector of percentages of people receiving vs not receiving voucher
de_summary_percent_str <- de_summary %>% 
    select(labels, percent) %>% deframe()

# Load data for advocates and county tabs
de_summary_table <- geo_data_nogeometry %>% 
    select("gsl", "entities", "sumlevel",
           "program_label", "program", "sub_program", "name", "GEOID",
           "rent_per_month", "hh_income", "person_income", 
           "spending_per_month","number_reported") %>%
    group_by(GEOID) %>% 
    mutate(tot = number_reported)

data_county <- geo_data_nogeometry %>%
    filter(number_reported > 0) %>%
    mutate(county = substr(GEOID, 3, 5)) %>%
    rowwise() %>% 
    mutate(above30 = sum(rent_30E, rent_35E, rent_40E),
           above50 = rent_50E) %>%
    group_by(county) %>%
    summarize(reported_HUD = sum(number_reported),
              rent_above30 = sum(above30),
              rent_above50 = sum(above50))

# Number of households spending above 30% and 50% of hh_income on rent.
number_county_30 = data_county %>%  select(reported_HUD,rent_above30,county) %>%
    dplyr::rename(
        'Household applied for Section 8 assisstance'=reported_HUD,
        'Household spending above 30% of income on rent'=rent_above30) %>%
    gather(Category, count, -c(county)) %>%
    ## na.rm = TRUE ensures all values are NA are taken as 0
    ggplot(aes(x=county,y=count))+
    geom_bar(aes(fill=Category),   # fill depends on cond2
             stat="identity",
             colour="black",    # Black outline for all
             position=position_dodge())+
    ylab("Number of households")+
    xlab("County")+
    labs(color = "Percentage of hh_income spent on rent")+
    ggtitle("Number of households soending above 50% of household income on rent")

number_county_50 = data_county %>%  select(reported_HUD,rent_above50,county) %>%
    dplyr::rename(
        'Household applied for Section 8 assisstance'=reported_HUD,
        'Household spending above 50% of income on rent'=rent_above50) %>%
    gather(Category, count, -c(county)) %>%
    ## na.rm = TRUE ensures all values are NA are taken as 0
    ggplot(aes(x=county,y=count))+
    geom_bar(aes(fill=Category),   # fill depends on cond2
             stat="identity",
             colour="black",    # Black outline for all
             position=position_dodge())+
    ylab("Number of households")+
    xlab("County")+
    labs(color = "Percentage of hh_income spent on rent")+
    ggtitle("Number of households soending above 50% of household income on rent")

# Proportion of households spending above 30% and 50% of hh_income on rent and not receiving assitance.
prop_county_30 = data_county %>% mutate(rent_above30=(rent_above30-reported_HUD)/rent_above30) %>%
    select(county,rent_above30) %>%
    dplyr::rename(
        'Households spending above 30% of income on rent'=rent_above30) %>%
    gather(Category, count, -c(county)) %>%
    ## na.rm = TRUE ensures all values are NA are taken as 0
    ggplot(aes(x=county,y=count))+
    geom_bar(aes(fill=Category),   # fill depends on cond2
             stat="identity",
             colour="black",    # Black outline for all
             position=position_dodge())+
    ylab("Proportion of households NOT receiving assistance")+
    xlab("County")+
    labs(color = "Percentage of hh_income spent on rent")+
    theme(legend.position="top") +
    ggtitle("")


prop_county_50 = data_county %>% mutate(rent_above50=(rent_above50-reported_HUD)/rent_above50) %>%
    select(county,rent_above50) %>%
    dplyr::rename(
        'Households spending above 50% of income on ren'=rent_above50
    ) %>%
    gather(Category, count, -c(county)) %>%
    ## na.rm = TRUE ensures all values are NA are taken as 0
    ggplot(aes(x=county,y=count))+
    geom_bar(aes(fill=Category),   # fill depends on cond2
             stat="identity",
             colour="black",    # Black outline for all
             position=position_dodge())+
    ylab("Proportion of households NOT receiving assistance")+
    xlab("County")+
    labs(color = "Percentage of hh_income spent on rent")+
    theme(legend.position="top") +
    ggtitle("")


# Data for Advocates Tab
#Statistics for GEOIDs
advoc_table <- geo_data_nogeometry %>%
    filter(number_reported > 0 ) %>%
    rowwise() %>%
    mutate(above30 = sum(rent_30E, rent_35E, rent_40E),
           above50=rent_50E) %>%
    group_by(GEOID) %>%
    summarize(reported_HUD=sum(number_reported),rent_above30=sum(above30),rent_above50=sum(above50)) %>%
    dplyr::rename(
        '# Households receiving assisstance'=reported_HUD,
        '# Households spending above 30% of income on rent'=rent_above30,
        '# Households spending above 50% of income on rent'=rent_above50,
    )


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
        
        # If the county is not selected, show the Delaware overall
        if(input$selectedCounty == "all"){
            mainplot_data <- geo_long 
        } else {
            mainplot_data <- geo_long %>%
                filter(COUNTYFP == input$selectedCounty)
        }
        
        # Determine the title of the plot
        county_list <- c(
            "all" = "All Delaware",
            "001" = "Kent County",
            "003" = "New Castle County",
            "005" = "Sussex County"
        )
        mainplot_title <- paste("Renters Potentially Eligible for Housing Choice Voucher",
                                county_list[[input$selectedCounty]],
                                sep = "<br>")
        
        mainplot_data <- mainplot_data %>%
            group_by(labels) %>%
            summarise(counts = sum(value, na.rm = T))
        
        mainplot_data %>%
            plot_ly(labels = ~labels, values = ~counts,
                    type = 'pie',
                    textinfo = 'label+percent',
                    insidetextorientation = 'horizontal',
                    showlegend = FALSE) %>%
            layout(title = list(text = mainplot_title),
                   margin = list(t = 100))
        
    })
    
    output$de_service_rate <- renderText(
        round(de_summary_percent_str[["Receiving Voucher"]])
        )
    
    output$main_text <- renderText(
        paste0("In Delaware, only ", round(de_summary_percent_str[["Receiving Voucher"]]),
               "% of the families needing Housing Choice Voucher are receiving it")
    )
    
    output$GEOID_selector <- renderUI({
        multiInput("GEOID_selector", "Choose GEOIDs",
                   choices = advoc_table$GEOID)
    })
    
    output$number_county <- renderPlotly({
        # If the county is not selected, show the Delaware overall
        if(input$selectedNumber == "30"){
            mainplot_data <- number_county_30 
        } 
        else {
            mainplot_data <- number_county_50
        }
        })
    output$prop_county <- renderPlotly({
        # If the county is not selected, show the Delaware overall
        if(input$selectedProp == "30"){
            mainplot_data <- prop_county_30 
        } 
        else {
            mainplot_data <- prop_county_50
        }
        })
    output$prop_county_50 <- renderPlotly({prop_county_50})
    output$advoc_table <- renderTable({advoc_table %>% filter(GEOID %in% input$GEOID_selector)})
    
})
