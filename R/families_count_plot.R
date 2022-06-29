# A Shiny module for showing the number of rent-burdened & voucher-participating 
# families across counties

families_count_plot_UI <- function(id) {
    plot_card(main_text = "New Castle County has the largest number of potentially-eligible families", 
              secondary_text = select_rent_burden(id),
              plot_content = plotlyOutput(NS(id, "number_county")))
}

families_count_plot_server <- function(id, .data_wide) {
    moduleServer(id, function(input, output, session) {
        output$number_county <- renderPlotly({
            
            # Render the plotly using the helper function
            plot_counts_counties(.data_wide,
                                 cutoff = as.numeric(input$threshold)) 
            
        })
        
    })
}
