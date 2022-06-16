overviewPieUI <- function(id){
    plotCard(main_text = list(textOutput(NS(id, "pie_main_text"))), 
             secondary_text = list(div("Rent-burdened families in "),
                                   selectInput(NS(id, "selected_county"), 
                                               label = NULL,
                                               choices = c("Delaware" = "all",
                                                           "New Castle County" = "003",
                                                           "Kent County" = "001",
                                                           "Sussex County" = "005"),
                                               width = "230px")),
             plot_content = plotlyOutput(NS(id, "overview_pie_plot")))
}

overviewPieServer <- function(id, geo_long){
    moduleServer(id, function(input, output, session) {
        # County List 
        county_list <- c(
            "all" = "Delaware",
            "001" = "Kent County",
            "003" = "New Castle County",
            "005" = "Sussex County")
        
        # Get the summarized data for rendering percentages
        de_summary <- geo_long %>% 
            group_by(labels) %>%
            summarise(counts = sum(value, na.rm = T)) %>%
            mutate(percent = 100 * counts / sum(counts))
        
        # Get the vector of percentages of people receiving vs not receiving voucher
        de_summary_percent_str <- de_summary %>% 
            select(labels, percent) %>% deframe()
        
        output$pie_main_text <- renderText({
            paste0("However, only ", round(de_summary_percent_str[["Receiving Voucher"]], 1),
                   "% of the Delaware families needing a voucher are receiving it")
            })
        
        
        output$overview_pie_plot <- renderPlotly({
            
            # If the county is not selected, show the Delaware overall
            if(input$selected_county == "all"){
                mainplot_data <- geo_long 
            } else {
                mainplot_data <- geo_long %>%
                    filter(COUNTYFP == input$selected_county)
            }
            
            cur_county_name <- county_list[[input$selected_county]]
            
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
    })
}
