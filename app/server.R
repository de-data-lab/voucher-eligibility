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

# Load summary table
DE_summary <- read_rds("data/acs_hud_de_geojoined_summary.rds")

# function to go to the lookup tool
goto_explore_tab <- function(session){
    updateNavbarPage(session, inputId = "main_page", selected = "Explore Your Neighborhood")
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    # Reactive values
    # Vector of selected GEOIDs
    selected_GEOIDs <- reactiveVal()
    
    # Reactive value for the message for the address lookup
    address_message <- reactiveVal("Example: \"411 Legislative Ave, Dover, DE\"")
    output$address_message <- renderText({ address_message() })
    
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
    
    # Address lookup
    # TODO: Server function
    output$GEOID_selector <- renderUI({
        multiInput("GEOID_selector", "Choose Census Tract",
                   choices = advoc_table$NAMELSAD)
    })
    
    # Server function for the rank plot
    rank_plot_server("rank_plot", selected_GEOIDs, acs_hud_de_geojoined)
    
    # Server function for the compare-to-DE plot
    compare_to_de_plot_server("compare_to_de", selected_GEOIDs, geo_data_nogeometry)
    
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
    
    # Geocode a given address
    found_GEOID <- reactiveValues(ids = vector())
    observeEvent(input$address_search, {
        # Try getting the GEOID based on a string, when fails, show an error
        tryCatch(
            {
                # Use censusxy to geocode one address 
                matched_address <- cxy_oneline(input$address,
                                               return = "geographies",
                                               vintage = "ACS2018_Current")
                # Get the matched GEOID
                matched_GEOID <- matched_address$geographies.Census.Tracts.GEOID
                # Add the matched GEOID to the reactive value
                found_GEOID$ids <- matched_GEOID
                
                # Get the census tract name and show it
                matched_tract_name <- matched_address$geographies.Census.Tracts.BASENAME
                address_message(paste0("Your census tract is: ", matched_tract_name))
                
                clicked_ids$Clicks <- c(clicked_ids$Clicks, found_GEOID$ids)
                
                clicked_ids$Clicks <- unique(clicked_ids$Clicks)
            },
            # Show the error message
            error = function(cond){
                address_message("No place found. Try formatting your address as: \"411 Legislative Ave, Dover, DE\"")
            }
        )
    }
    )
    
    # Observe for the clicking the "Clear All" button
    observeEvent(input$clear, {
        selected_GEOIDs(NULL)
    })
})
