library(shiny)
library(tidyverse)
library(plotly)
library(sf)

PYTHON_DEPENDENCIES = c('pip', 'censusgeocode')
virtualenv_dir = Sys.getenv('VIRTUALENV_NAME')
python_path = Sys.getenv('PYTHON_PATH')
# Create virtual env and install dependencies
reticulate::virtualenv_create(envname = virtualenv_dir, python = python_path)
reticulate::virtualenv_install(virtualenv_dir, packages = PYTHON_DEPENDENCIES, ignore_installed=TRUE)
reticulate::use_virtualenv(virtualenv_dir, required = T)
reticulate::source_python("scripts/geocode.py")

source("scripts/plotly_settings.R")
source("scripts/advocates.R")
source("scripts/plot_prop_counties.R")
source("scripts/plot_prop_census.R")
source("scripts/update_map.R")
source("scripts/plot_counts_counties.R")
source("scripts/plot_table_desc.R")

# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
    st_drop_geometry()


# Dictionary of counties and keys
county_list <- c(
    "all" = "Delaware",
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
    mutate(tot = number_reported)

# Summary table for 30 and 50 
DE_pct <- advoc_table %>% 
    group_by() %>%
    summarise(across(c(receiving_assistance = `% Receiving assisstance`,
                       rent_30 = `% Spending 30%+ of income on rent`,
                       rent_50 = `% Spending 50%+ of income on rent`),
                     ~round(mean(.), 1))) %>% 
    as.list()

# function to go to the lookup tool
goto_explore_tab <- function(session){
    updateNavbarPage(session, inputId = "main_page", selected = "Explore Your Neighborhood")
}

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
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
    
    output$mainplot <- renderPlotly({
        
        # If the county is not selected, show the Delaware overall
        if(input$selectedCounty == "all"){
            mainplot_data <- geo_long 
        } else {
            mainplot_data <- geo_long %>%
                filter(COUNTYFP == input$selectedCounty)
        }
        
        cur_county_name <- county_list[[input$selectedCounty]]
        
        mainplot_data <- mainplot_data %>%
            group_by(labels) %>%
            summarise(counts = sum(value, na.rm = T))
        
        mainplot_data %>%
            plot_ly(labels = ~labels, values = ~counts,
                    type = 'pie',
                    textinfo = 'label+percent',
                    customdata = c("not receiving voucher", "receiving voucher"),
                    textfont = list(size = 15),
                    texttemplate = "%{label} <br> %{percent:.1%}",
                    hoverinfo = "text",
                    hovertemplate = str_wrap_br(
                        paste0("In ", cur_county_name,
                               ", %{percent:.1%} of eligible families are %{customdata}",
                               "<extra></extra>"),
                        width = 60
                    ),
                    insidetextorientation = 'horizontal',
                    showlegend = FALSE,
                    marker = list(
                        colors = c("#FC8D62", # Brewer Set 2 orange
                                   "#66C2A5") # Brewer Set 2 green
                    )) %>%
            layout(margin = list(t = 50)) %>%
            format_plotly()
        
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
            current_plot <- plot_counts_counties(geo_data_nogeometry, 30) 
        } 
        else {
            current_plot <- plot_counts_counties(geo_data_nogeometry, 50) 
        }
        return(current_plot)
    })
    
    output$prop_counties <- renderPlotly({
        if(input$selectedProp == "30"){
            plot_prop_counties(geo_long, input$selectedProp)
        } 
        else {
            plot_prop_counties(geo_long_50, input$selectedProp)
        }
    })
    
    output$downloadData <- downloadHandler(
        filename = function() {
            paste("voucher_data.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>% filter(GEOID %in% clicked_ids$Clicks) %>%  
                          dplyr::rename('Census Tract' = tract) %>% 
                          select('Census Tract', GEOID, '% Receiving assisstance',
                                 '% Spending 30%+ of income on rent',
                                 '% Spending 50%+ of income on rent',
                                 '# Receiving assisstance',
                                 '# Spending 30%+ of income on rent',
                                 '# Spending 50%+ of income on rent'),
                      file, row.names = FALSE, col.names=T)
        }
    )
    
    output$downloadAll <- downloadHandler(
        filename = function() {
            paste("voucher_data_All.csv")
        },
        content = function(file) {
            write.csv(advoc_table %>%
                          dplyr::rename('Census Tract' = tract) %>% 
                          select('Census Tract', GEOID, '% Receiving assisstance',
                                 '% Spending 30%+ of income on rent',
                                 '% Spending 50%+ of income on rent',
                                 '# Receiving assisstance',
                                 '# Spending 30%+ of income on rent',
                                 '# Spending 50%+ of income on rent') ,
                      file, row.names = FALSE, col.names=T)
        }
    )
    
    output$advocmap <- renderLeaflet({advoc_map})
    clicked_ids <- reactiveValues(Clicks=vector())

    # If the map is clicked, update the reactive value
    observeEvent(input$advocmap_shape_click, {
        clicked_tract <- input$advocmap_shape_click
        # Add a new selected GEOID to the reactive value
        clicked_ids$Clicks <- c(clicked_ids$Clicks, clicked_tract$id)
        removePoly <- clicked_ids$Clicks[duplicated(clicked_ids$Clicks)]
        remove <- FALSE
        if(length(removePoly) > 0){
            remove=TRUE
        }
        # Avoid duplicates in GEOIDs
        clicked_ids$Clicks <- clicked_ids$Clicks[!clicked_ids$Clicks %in% clicked_ids$Clicks[duplicated(clicked_ids$Clicks)]]
        
            if(remove == TRUE){
                new_data <- geo_data %>% 
                    filter(GEOID %in% (removePoly))
                update_map(new_data, to_state = "deselect",addr=FALSE,latt=NA,long=NA)
            }
        else {
            new_data <- geo_data %>% 
                filter(GEOID %in% (clicked_ids$Clicks))
            update_map(new_data, to_state = "select",addr=FALSE,latt=NA,long=NA)
            
        }
        if (length(clicked_ids$Clicks)>0){
            agg_selected <- advoc_table %>% 
                filter(GEOID %in% clicked_ids$Clicks)
            agg_notselected <- advoc_table %>% 
              filter(!(GEOID %in% clicked_ids$Clicks))
            #print(length(agg_selected$GEOID))
            #print(length(agg_notselected$GEOID))
            agg_receiving <- round((sum(agg_selected$`# Receiving assisstance`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
            agg_30 <- round((sum(agg_selected$`# Spending 30%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
            agg_50 <- round((sum(agg_selected$`# Spending 50%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
            n_above_receving<- agg_notselected %>% filter(`# Receiving assisstance`>agg_receiving) %>% nrow
            n_above_30<- agg_notselected %>% filter(`# Spending 30%+ of income on rent`>agg_30) %>% nrow
            n_above_50<- agg_notselected %>% filter(`# Spending 50%+ of income on rent`>agg_50) %>% nrow
            n_below_receving<- agg_notselected %>% filter(`# Receiving assisstance`<agg_receiving) %>% nrow
            n_below_30<- agg_notselected %>% filter(`# Spending 30%+ of income on rent`<agg_30) %>% nrow
            n_below_50<- agg_notselected %>% filter(`# Spending 50%+ of income on rent`<agg_50) %>% nrow
            output$table_desc <- renderText({paste("Currently selected census tracts has in total: <br><br><b>",agg_30,"% </b>
                             of households spending above 30% of income on rent <br><font color=\"#43a2ca\"><i>(<b>",n_above_30," 
                             </b>census tracts are spending above 30% of income on rent and <br><b>",n_below_30,
                             " </b>census tracts are spending above 30% of income on rent)</i></font>, <br><br><b>",agg_50,"% </b> 
                                   of households spending above 50% of income on rent <br><font color=\"#43a2ca\"><i>(<b>",n_above_50," 
                             </b>census tracts are spending above 50% of income on rent and <br><b>",n_below_50,
                             " </b>census tracts are spending above 50% of income on rent)</i></font>,<br><br>",agg_receiving,"% </b> of
                             households receiving Housing Choice Voucher <br><font color=\"#43a2ca\"><i>(<b>",n_above_receving," 
                             </b>census tracts are receving higher number of vouchers and <br><b>",n_below_receving,
                             " </b>census tracts are receving lower number of vouchers)</i></font><br><b>",  sep = " ")})
            output$table_desc_plot <- renderPlotly({plot_table_desc(agg_selected,TRUE)})
        }
        else { 
            output$table_desc <- renderText({"Select census tracts"})
            output$table_desc_plot <- renderPlotly({plot_table_desc(agg_selected,FALSE)})
        }
    })
    
    
    # Observe the click to the advocates page
    observeEvent(input$to_advocates_page, {
        goto_explore_tab(session)
    })
    observeEvent(input$to_advocates_page_bottom, {
        goto_explore_tab(session)
    })
    
    # Geocode a given address via python when the search is initiated
    found_GEOID <- reactiveValues(ids=vector())
    observeEvent(input$address_search, {
        # Try getting the GEOID based on a string, when fails, show an error
        tryCatch(
            {
                found_GEOID$ids <- return_geoid(input$address)
                
                current_tract_name <- geo_data %>%
                    filter(GEOID == found_GEOID$ids) %>%
                    pull(tract)

                address_message(paste0("Your census tract is: ", current_tract_name))
                
                clicked_ids$Clicks <- c(clicked_ids$Clicks, found_GEOID$ids)
                
                clicked_ids$Clicks <- unique(clicked_ids$Clicks)
                
                geo <- advoc_table %>%
                    filter(GEOID %in% (found_GEOID$ids))
                
                new_data <- geo_data %>% 
                    filter(GEOID %in% (clicked_ids$Clicks))
  
                update_map(new_data, to_state = "select",
                           addr = TRUE,
                           latt = geo$latt,
                           long = geo$long)
            },
            # Show the error message
            error = function(cond){
                address_message("No place found. Try formatting your address as: \"411 Legislative Ave, Dover, DE\"")
            }
        )
    }
    )
    
    output$prop_census <- renderPlotly({
        if(input$selectedCensusProp == "30"){
            plot_prop_census(30, clicked_ids$Clicks)
            
        } 
        else if(input$selectedCensusProp == "50") {
            plot_prop_census(50, clicked_ids$Clicks)
        }
    })
    
    output$bar_title <- 
      renderText({
        if(input$selectedCensusProp == "30"){
            "% Household Spending 30%+ of income on rent (for All Census Tracts)"
      }
      if(input$selectedCensusProp == "50"){
          "% Household Spending 50%+ of income on rent (for All Census Tracts)"
      }
    })
    
    output$advoc_table <- renderTable({
        output_table <- advoc_table %>% 
            filter(GEOID %in% clicked_ids$Clicks) %>%  
            dplyr::rename('Census Tract' = tract) %>% 
            select('Census Tract', GEOID, '% Receiving assisstance',
                   '% Spending 30%+ of income on rent',
                   '% Spending 50%+ of income on rent') 
        return(output_table)
    }, align='ccccc')
    
    output$table_desc_plot <- renderPlotly({plot_table_desc("", FALSE)})
    output$table_desc <- renderText({"Select census tracts"})
    output$bar_title <- renderText({"% Household Spending 30%+ of income on rent (for All Census Tracts)"})
    
    # Observe for the clicking the "Clear All" button
    observeEvent(input$clear, {
      removePoly <- clicked_ids$Clicks
      clicked_ids$Clicks<-vector()
      print(removePoly)
      remove <- FALSE
      if(length(removePoly) > 0){
        remove <- TRUE
      }
      if(remove == TRUE){
        new_data <- geo_data %>% 
          filter(GEOID %in% (removePoly))
        update_map(new_data, to_state = "deselect",addr=FALSE,latt=NA,long=NA)
        output$table_desc <- renderText({"Select census tracts"})
        output$table_desc_plot <- renderPlotly({plot_table_desc("",FALSE)})
      }
    })
})
