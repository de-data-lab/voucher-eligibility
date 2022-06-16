# A Shiny module for showing the number of rent-burdened & voucher-participating 
# families across counties
source("R/select_rent_burden.R")

families_count_plot_UI <- function(id) {
    plot_card(main_text = "New Castle County has the largest number of potentially-eligible families", 
             secondary_text = select_rent_burden(id),
             plot_content = plotlyOutput(NS(id, "number_county")))
}

families_count_plot_server <- function(id, geo_data_nogeometry) {
    
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
    
    
    moduleServer(id, function(input, output, session) {
        output$number_county <- renderPlotly({
            if(input$threshold == "30"){
                plot_counts_counties(geo_data_nogeometry, 30) 
            } 
            else {
                plot_counts_counties(geo_data_nogeometry, 50) 
            }
        })
        
    })
}
