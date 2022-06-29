# A Shiny module for the pie chart showing an overview of the 
# proportion of voucher participants among eligible families

# County List 
county_list <- c("all" = "Delaware",
                 "001" = "Kent County",
                 "003" = "New Castle County",
                 "005" = "Sussex County")
# County list but names and values reversed
county_keys <- setNames(names(county_list), county_list)


overview_pie_UI <- function(id){
    plot_card(main_text = textOutput(NS(id, "pie_main_text")), 
              secondary_text = list(div("Rent-burdened families in "),
                                    selectInput(NS(id, "selected_county"), 
                                                label = NULL,
                                                choices = county_keys,
                                                width = "230px")),
              plot_content = plotlyOutput(NS(id, "overview_pie_plot")))
}

overview_pie_server <- function(id, geo_long){
    moduleServer(id, function(input, output, session) {
        # Drop geometry 
        geo_long <- geo_long %>%
            st_drop_geometry()
        
        # Calculate the DE summary table
        de_summary <- geo_long %>%
            get_voucher_summary()
        
        # Get the vector of percentages of people receiving vs not receiving voucher
        de_summary_percent_str <- de_summary %>% 
            select(labels, percent) %>% deframe()
        
        # Create a text showing the overall % of people receiving voucher over
        # eligible families
        output$pie_main_text <- renderText({
            paste0("However, only ", round(de_summary_percent_str[["Receiving Voucher"]], 1),
                   "% of the Delaware families needing a voucher are receiving it")
        })
        
        output$overview_pie_plot <- renderPlotly({
            # If the county is not selected, show the Delaware overall
            if(input$selected_county == "all"){
                # Use previously-calculated summary
                mainplot_data <- de_summary
            } else if(input$selected_county != "all") {
                # Calculate a county-specific summary table
                mainplot_data <- geo_long %>%
                    filter(COUNTYFP == input$selected_county) %>%
                    get_voucher_summary()
            }
            
            # Get the name of selectd county
            cur_county_name <- county_list[[input$selected_county]]
            
            # Create the pie chart
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
