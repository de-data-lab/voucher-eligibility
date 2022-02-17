library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(reticulate)

PYTHON_DEPENDENCIES = c('pip', 'censusgeocode')
virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
python_path = Sys.getenv('PYTHON_PATH')
# Create virtual env and install dependencies
reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
reticulate::use_virtualenv(virtualenv_dir, required = T)
source_python("scripts/geocode.py")


source("scripts/plotly_settings.R")
source("scripts/advocates.R")
source("scripts/county.R")
source("scripts/plot_prop_counties.R")


# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
    st_drop_geometry()

# Dictionary of counties and keys
county_list <- c(
    "all" = "All Delaware",
    "001" = "Kent County",
    "003" = "New Castle County",
    "005" = "Sussex County")

# Update the county names
geo_data_nogeometry <- geo_data_nogeometry %>%
    mutate(county_name = str_remove(recode(COUNTYFP, !!!county_list),
                                    " County"))

# Reshape the dataset into the long format for summarizing 
geo_long <- geo_data_nogeometry %>%
    mutate(number_not_using = eligible_renters - number_reported) %>%
    select(GEOID, COUNTYFP, county_name, number_not_using, number_reported) %>%
    pivot_longer(cols = c("number_not_using", "number_reported")) %>%
    mutate(labels = case_when(name == "number_not_using" ~ "Not Receiving Voucher",
                              name == "number_reported" ~ "Receiving Voucher"))

geo_long_50 <- geo_data_nogeometry %>%
    mutate(number_not_using = eligible_renters_50pct - number_reported) %>%
    select(GEOID, COUNTYFP, county_name, number_not_using, number_reported) %>%
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
        mainplot_title <- paste("Renters Potentially Eligible for <br> Housing Choice Voucher",
                                county_list[[input$selectedCounty]],
                                sep = "<br>")
        
        mainplot_data <- mainplot_data %>%
            group_by(labels) %>%
            summarise(counts = sum(value, na.rm = T))
        
        mainplot_data %>%
            plot_ly(labels = ~labels, values = ~counts,
                    type = 'pie',
                    textinfo = 'label+percent',
                    hoverinfo = "text",
                    hovertemplate = paste("%{value} Families",
                                          "<extra></extra>",
                                          sep = "<br>"),
                    insidetextorientation = 'horizontal',
                    showlegend = FALSE,
                    marker = list(
                        colors = c("#FC8D62", # Brewer Set 2 orange
                                   "#66C2A5") # Brewer Set 2 green
                    )) %>%
            layout(title = list(text = mainplot_title,
                                pad = list(b = 20),
                                y = 0.95,
                                yanchor = "top"),
                   margin = list(t = 100)) %>%
            plotly_hide_modebar()
        
    })
    
    output$main_text <- renderText(
        paste0("However, only ", round(de_summary_percent_str[["Receiving Voucher"]]),
               "% of the Delaware families needing a voucher are receiving it")
    )
    
    output$GEOID_selector <- renderUI({
        multiInput("GEOID_selector", "Choose Census Tract",
                   choices = advoc_table$NAMELSAD)
    })
    
    output$number_county <- renderPlotly({
        if(input$selectedNumber == "30"){
            current_plot <- number_county_30 
        } 
        else {
            current_plot <- number_county_50
        }
        current_plot %>% 
            ggplotly() %>%
            plotly_disable_zoom() %>%
            plotly_hide_modebar
        })
    
    output$prop_counties <- renderPlotly({
        if(input$selectedProp == "30"){
            plot_prop_counties(geo_long)
        } 
        else {
            plot_prop_counties(geo_long_50)
        }
    })
    
    output$prop_county <- renderPlotly({
        if(input$selectedProp == "30"){
            current_plot <- prop_county_30
        } 
        else {
            current_plot <- prop_county_50
        }
        current_plot %>%
            ggplotly() %>%
            plotly_disable_zoom() %>%
            plotly_hide_modebar
        })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("voucher_data.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>% filter(NAMELSAD %in% clicked_ids$Clicks) %>%  
                          dplyr::rename('Census Tract'=NAME) %>% 
                          select('Census Tract',GEOID,'# Receiving assisstance',
                                 '# Spending 30%+ of income on rent',
                                 '# Spending 50%+ of income on rent'),
                      file, row.names = FALSE,col.names=T)
        }
    )
    
    output$downloadAll <- downloadHandler(
        filename = function() {
            paste("voucher_data_All.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>%
                          dplyr::rename('Census Tract'=NAME) %>% 
                          select('Census Tract',GEOID,'# Receiving assisstance',
                                 '# Spending 30%+ of income on rent',
                                 '# Spending 50%+ of income on rent'),
                      file, row.names = FALSE,col.names=T)
        }
    )
    
     output$advocmap <- renderLeaflet({advoc_map})
     clicked_ids <- reactiveValues(Clicks=vector())
    
    # #if map is clicked, set values
     observeEvent(input$advocmap_shape_click,{
         click = input$advocmap_shape_click
         selected_geoid=input$advocmap_shape_click$id
         clicked_ids$Clicks <- c(clicked_ids$Clicks, click$id) # name when clicked, id when unclicked
         #print(clicked_ids$Clicks)
         removePoly=clicked_ids$Clicks[duplicated(clicked_ids$Clicks)]
         remove=FALSE
         if(length(removePoly)>0){
             remove=TRUE
         }
         clicked_ids$Clicks <- clicked_ids$Clicks[!clicked_ids$Clicks %in% clicked_ids$Clicks[duplicated(clicked_ids$Clicks)]]
         
         #clicked_ids$Clicks=!clicked_ids$Clicks %in% clicked_ids$Clicks[duplicated(clicked_ids$Clicks)]
         #print(clicked_ids$Clicks)
         #print(sub)
         if(is.null(click))
             return()
         else
             if(remove==TRUE){
                 sub <- shape %>% filter(NAMELSAD %in% (removePoly))
                 leafletProxy("advocmap") %>% addTiles() %>%
                 addPolygons(data=sub,
                             fillColor = "#bdc9e1",
                             stroke = TRUE, fillOpacity = 0.2, smoothFactor = 0.5,
                             color = "#2b8cbe",opacity = 1,weight=2,
                             highlight=highlightOptions(fillOpacity = 0.8,
                                                        color = "#b30000",
                                                        weight = 2,
                                                        bringToFront=TRUE),
                             label= ~NAMELSAD, layerId = ~NAMELSAD)
             }
             else{
                sub <- shape %>% filter(NAMELSAD %in% (clicked_ids$Clicks))
                leafletProxy("advocmap") %>% addTiles() %>%
                addPolygons(data=sub,
                            fillColor = "#b30000",color = "#2b8cbe",opacity = 1,weight=2,
                            fillOpacity = 0.8, smoothFactor = 0.5,
                            highlight=highlightOptions(fillOpacity = 0.8,
                                                       color = "#b30000",
                                                       weight = 2,
                                                       bringToFront=TRUE),
                            label= ~NAMELSAD, layerId = ~NAMELSAD)
             }
            
             output$advoc_table <- renderTable({advoc_table %>% filter(NAMELSAD %in% clicked_ids$Clicks) %>%  
                     dplyr::rename('Census Tract'=NAME) %>% 
                     select('Census Tract',GEOID,'# Receiving assisstance',
                            '# Spending 30%+ of income on rent',
                            '# Spending 50%+ of income on rent') })

     })
     
    # Observe the click to the advocates page
    observeEvent(input$to_advocates_page, {
        updateNavbarPage(session, inputId =  "main_page", selected = "For Advocates")
    })
    observeEvent(input$to_advocates_page_bottom, {
        updateNavbarPage(session, inputId =  "main_page", selected = "For Advocates")
    })
    
    # Address lookup routine
    # current_GEOID <- eventReactive(input$address_search,
    #                                {tryCatch(
    #                                    {
    #                                        return_geoid(input$address)
    #                                    },
    #                                 error = function(cond){
    #                                     "No GEOID found"
    #                                     }
    #                                    )
    #                                    })
    found_GEOID <- reactiveValues(ids=vector())
    # not_found <- reactiveValues(ids=vector())
    observeEvent(input$address_search,
                                   {tryCatch(
                                       {
                                           found_GEOID$ids <- return_geoid(input$address)
                                           output$current_GEOID <-  renderText({found_GEOID$ids})
                                       },
                                       error = function(cond){
                                           found_GEOID$ids <- "No GEOID found"
                                           output$current_GEOID <-  renderText({found_GEOID$ids})
                                       }
                                   )
                                   })
    #found_GEOID$ids <- current_GEOID()
    #output$current_GEOID <-  renderText({current_GEOID()})
    #output$current_GEOID <-  renderText({found_GEOID$ids})
    # output$result <- renderText({"New"})
    # observeEvent(input$current_GEOID,{output$result <- renderText({"Hi"})
    # })
    
    # output$result <- renderPrint({tryCatch(
    #     {
    #         return_geoid(input$address)
    #     },
    #     error = function(cond){
    #         "No GEOID found"
    #     })
    #     })
    # observe({
    #     input$current_GEOID()
    #     output$result <-  renderText({"Changed"})})
    # output$advocmap <-renderLeaflet({leafletProxy("advocmap") %>% addTiles() %>%
    #     addPolygons(data=sub,
    #                 fillColor = "#b30000",color = "#2b8cbe",opacity = 1,weight=2,
    #                 fillOpacity = 0.8, smoothFactor = 0.5,
    #                 highlight=highlightOptions(fillOpacity = 0.8,
    #                                            color = "#b30000",
    #                                            weight = 2,
    #                                            bringToFront=TRUE),
    #                 label= ~NAMELSAD, layerId = ~NAMELSAD)
    # })
    
})
