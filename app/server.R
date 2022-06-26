library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(censusxy)

source("R/plotly_settings.R")
source("R/plot_prop_counties.R")
source("R/plot_rank_plot.R")
source("R/plot_counts_counties.R")
source("R/rank_plot.R")

# Load Data
acs_hud_de_geojoined <- read_rds("data/acs_hud_de_geojoined.rds") %>%
    st_transform('+proj=longlat +datum=WGS84')
geo_data_nogeometry <- acs_hud_de_geojoined %>% 
    st_drop_geometry()

## Count long data
acs_hud_de_geojoined_count_long <- read_rds("data/acs_hud_de_geojoined_count_long.rds")
acs_hud_de_count_long <- acs_hud_de_geojoined_count_long %>%
    st_drop_geometry()

# function to go to the lookup tool
goto_explore_tab <- function(session){
    updateNavbarPage(session, inputId = "main_page", selected = "Explore Your Neighborhood")
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    # Reactive values
    # Vector of selected GEOIDs
    selected_GEOIDs <- reactiveVal()
    
    
    # Observe the URL parameter and route the page to an appropriate tab
    observe({
        query <- parseQueryString(session$clientData$url_search)
        query1 <- paste(names(query), query, sep = "=", collapse=", ")
        if(query1 == "page=explore"){
            goto_explore_tab(session)
        }
    })
    
    # Server function to draw the pie chart
    overview_pie_server("overview_pie", acs_hud_de_geojoined_count_long)
    # Server function for the families count plot 
    families_count_plot_server("familiesCountPlot", geo_data_nogeometry)
    # Server function for the families prop plot
    familiesPropPlotServer("familiesPropPlot", acs_hud_de_count_long)
    
    # Server function for the explore map
    map_server("explore", selected_GEOIDs, acs_hud_de_geojoined)
    # Server function for the rank plot
    rank_plot_server("rank_plot", selected_GEOIDs, acs_hud_de_geojoined)
    # Server function for the compare-to-DE plot
    compare_to_de_plot_server("compare_to_de", selected_GEOIDs, geo_data_nogeometry)
    # Server function for the address search
    address_search_server("address_search", selected_GEOIDs)
    
    # Render the tale
    output$advoc_table <- renderTable({
        geo_data_nogeometry %>% 
            filter(GEOID %in% selected_GEOIDs()) %>%  
            select(tract, GEOID, prop_serviced, prop_above30, prop_above50) %>%
            # Mutate for rendering 
            mutate(across(c(prop_serviced, prop_above30, prop_above50),
                          ~sprintf("%.1f%%", .))) %>% 
            # Rename for rendering
            rename("Census Tract" = tract,
                   "Receiving assisstance" = prop_serviced,
                   "Spending 30%+ income on rent" = prop_above30,
                   "Spending 50%+ income on rent" = prop_above50)
    }, align = "c")

    # Download data
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("voucher_data.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>% filter(GEOID %in% selected_GEOIDs()) %>%  
                          dplyr::rename("Census Tract" = tract) %>% 
                          select("Census Tract", GEOID, "% Receiving assisstance",
                                 "% Spending 30%+ of income on rent",
                                 "% Spending 50%+ of income on rent",
                                 "# Receiving assisstance",
                                 "# Spending 30%+ of income on rent",
                                 "# Spending 50%+ of income on rent"),
                      file, row.names = FALSE, col.names=T)
        }
    )
    
    # Download all data
    output$downloadAll <- downloadHandler(
        filename = function() {
            paste("voucher_data_All.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>%
                          dplyr::rename("Census Tract" = tract) %>% 
                          select("Census Tract", GEOID, "% Receiving assisstance",
                                 "% Spending 30%+ of income on rent",
                                 "% Spending 50%+ of income on rent",
                                 "# Receiving assisstance",
                                 "# Spending 30%+ of income on rent",
                                 "# Spending 50%+ of income on rent") ,
                      file, row.names = FALSE, col.names=T)
        }
    )
    
    # Observe the click to the explore page
    observeEvent(input$to_explore_page, {
        goto_explore_tab(session)
    })
    observeEvent(input$to_explore_page_bottom, {
        goto_explore_tab(session)
    })
    
    # Observe for the clicking the "Clear All" button
    observe({ 
        selected_GEOIDs(NULL)
    }) %>%
        bindEvent(input$clear)
})
