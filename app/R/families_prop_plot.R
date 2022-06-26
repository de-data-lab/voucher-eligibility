# A Shiny module for the plot showing the proportions of rent-burdened families
# receiving vouchers across Delaware counties
source("R/select_rent_burden.R")

families_prop_plot_UI <- function(id) {
    plot_card(main_text = "Sussex County is struggling the most to help Delaware families", 
              secondary_text = select_rent_burden(id, prefix = NULL),
              plot_content = plotlyOutput(NS(id, "prop_counties")))
}

familiesPropPlotServer <- function(id, .data_long) {
    moduleServer(id, function(input, output, session) {
        output$prop_counties <- renderPlotly({
            plot_prop_counties(.data_long, input$threshold)
        })
    })
}
