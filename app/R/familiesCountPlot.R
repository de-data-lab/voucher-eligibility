# A Shiny module for showing the number of rent-burdened & voucher-participating 
# families across counties

familiesCountPlotUI <- function(id) {
    plotCard(main_text = "New Castle County has the largest number of potentially-eligible families", 
             secondary_text = list(div("Number of "),
                                   selectInput(NS(id, "threshold"), 
                                               label = NULL,
                                               choices = c("Rent-burdened" = "30",
                                                           "Severely rent-burdened" = "50"),
                                               selected = "30",
                                               width = 250),
                                   div("families")),
             plot_content = plotlyOutput(NS(id, "number_county")))
}

familiesCountPlotServer <- function(id, geo_data_nogeometry) {
    moduleServer(id, function(input, output, session) {
        output$number_county <- renderPlotly({
            if(input$threshold == "30"){
                current_plot <- plot_counts_counties(geo_data_nogeometry, 30) 
            } 
            else {
                current_plot <- plot_counts_counties(geo_data_nogeometry, 50) 
            }
            return(current_plot)
        })
        
    })
    
    
}
