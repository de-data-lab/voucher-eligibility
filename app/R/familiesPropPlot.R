# A Shiny module for the plot showing the proportions of rent-burdened families
# receiving vouchers across Delaware counties
source("R/selectRentBurden.R")

familiesPropPlotUI <- function(id) {
    plotCard(main_text = "Sussex County is struggling the most to help Delaware families", 
             secondary_text = selectRentBurden(id, prefix = NULL),
             plot_content = plotlyOutput(NS(id, "prop_counties")))
}

familiesPropPlotServer <- function(id, geo_data_nogeometry) {
    
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
      output$prop_counties <- renderPlotly({
          if(input$threshold == "30"){
              plot_prop_counties(geo_long, input$threshold)
          } 
          else {
              plot_prop_counties(geo_long_50, input$threshold)
          }
      })
      
  })
}
