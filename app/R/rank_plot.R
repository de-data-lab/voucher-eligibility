# A Shiny module for the rank plot
source("R/plot_prop_census.R")
rank_plot_UI <- function(id) {
    tagList(
        div(class = "explore-description-container",
                 textOutput(NS(id, "rank_text")),
                 span(class = "explore-select-input",
                      selectInput(NS(id, "selection"), 
                                  label = NULL,
                                  choices = c("rent-burdened" = "30",
                                              "severely rent-burdened" = "50",
                                              "receiving voucher" = "receiving_voucher"),
                                  selected = "30",
                                  width = 250)
                 )),
        div(class = "bar-graph",
            plotlyOutput(NS(id, "plot")))
    )
 
}

rank_plot_server <- function(id, selected_GEOIDs, .data) {
    moduleServer(id, function(input, output, session) {
        
        observe({
            # Calculate the plot 
            plot_list <- plot_prop_census(.data, 
                                          threshold = input$selection,
                                          selected_GEOIDs =  selected_GEOIDs())
            # Render Plotly
            output$plot <- renderPlotly({
                plot_list$plot
            })
            
            # Get the number of selected tracts
            n_selected <- selected_GEOIDs() %>% length()
            if(length(selected_GEOIDs()) > 0){
                rank_text_region <- str_glue("the selected {n_selected} tracts")
                rank_text_pct <- plot_list$selected_mean
            } else {
                rank_text_region <- "Delaware"
                rank_text_pct <- plot_list$overall_mean
            }
            
            # Render the text
            output$rank_text <- renderText({
                str_glue("{rank_text_pct}% of families in {rank_text_region} are ")
            })
        })
    })
}
