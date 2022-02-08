library(shiny)
library(tidyverse)
library(plotly)
library(sf)

source("Scripts/advocates.R")
source("Scripts/county.R")

# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
    st_drop_geometry()
#print(length(unique(geo_data_nogeometry$GEOID)))
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

# Dictionary of counties and keys
county_list <- c(
    "all" = "All Delaware",
    "001" = "Kent County",
    "003" = "New Castle County",
    "005" = "Sussex County")


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {

    output$mainplot <- renderPlotly({
        
        # If the county is not selected, show the Delaware overall
        if(input$selectedCounty == "all"){
            mainplot_data <- geo_long 
        } else {
            mainplot_data <- geo_long %>%
                filter(COUNTYFP == input$selectedCounty)
        }
        
        # Determine the title of the plot
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
    
    output$main_text <- renderText(
        paste0("However, only ", round(de_summary_percent_str[["Receiving Voucher"]]),
               "% of the Delaware families needing a voucher are receiving it")
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
    #output$advoc_table <- renderTable({advoc_table %>% filter(GEOID %in% input$GEOID_selector)})
    
    output$advocmap <- renderLeaflet({advoc_map})
    clicked_ids <- reactiveValues(Clicks=list())
    
    #if map is clicked, set values
    observe({
        click = input$advocmap_shape_click
        selected_geoid=input$advocmap_shape_click$id
        #print(click$id)
        sub=shape[shape$GEOID==selected_geoid,c("NAME","NAMELSAD")]
        #clicked_ids$Clicks <- c(clicked_ids$Clicks, click$id) # name when clicked, id when unclicked
        print(clicked_ids$Clicks)
        if(is.null(click))
            return()
        else
            output$advoc_table <- renderTable({advoc_table %>% filter(GEOID %in% selected_geoid)})
        
    })
    
    # Observe the click to the advocates page
    observeEvent(input$to_advocates_page, {
        updateNavbarPage(session, inputId =  "main_page", selected = "For Advocates")
    })
})
