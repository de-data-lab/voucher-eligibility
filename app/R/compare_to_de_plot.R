# Compare to Delaware plot, showing the rent-burdened, severely-rent burdened, 
# and people receiving vouchers against Delaware
source("R/get_pct_table.R")

compare_to_de_plot_UI <- function(id) {
    div(class = "explore-bar-container",
        div(class = "bar-graph",
            div(class = "explore-bar-title",
                "Percent of families that are:"),
            plotlyOutput(NS(id, "plot"))
        )
        
    )
}

compare_to_de_plot_server <- function(id, selected_GEOIDs, .data) {
    moduleServer(id, function(input, output, session) {
        
        recode_scheme <- c("rent_above30" = "Rent-burdened",
                           "rent_above50" = "Severely rent-burdened",
                           "number_reported" = "Receiving voucher")
        
        # Construct all Delaware data
        table_plot_data <- .data %>% 
            get_pct_table()
        
        # Add the level column indicating that it's delaware
        table_plot_data <- table_plot_data %>% 
            mutate(level = "Delaware")
        
        # Add labels for the Delaware data
        table_plot_data <- table_plot_data %>% 
            mutate(info_type_label = recode(name, !!!recode_scheme)) %>%
            mutate(pct_rounded = round(pct, 1)) %>%
            mutate(plotly_label = str_glue(
                "In all Delaware, {pct_rounded}% of the families
                are {str_to_lower(info_type_label)} "))
        
        
        output$plot <- renderPlotly({
            # Track if a census tract is selected
            is_selected <- length(selected_GEOIDs()) > 0
            
            
            # Insert line breaks to the plotly label
            table_plot_data <- table_plot_data %>% 
                rowwise() %>%
                mutate(plotly_label = str_wrap_br(plotly_label, width = 50)) %>%
                ungroup()
            
            # Calculate the maximum value of x axis, used for calculating x range
            xmax <- max(table_plot_data$pct) * 1.50
            
            # For both conditions, we need All Delaware bars
            comparison_plot <- plot_ly() %>% 
                add_bars(data = table_plot_data %>% filter(level == "Delaware"),
                         x = ~pct, y = ~info_type_label,
                         marker = list(color = "#66C2A5"),
                         name = "Delaware",
                         text = ~pct,
                         texttemplate = "%{x:.1f}%",
                         insidetextanchor = "end",
                         textposition = "outside",
                         textangle = 0,
                         hovertext = ~plotly_label,
                         hoverinfo = "text")  %>%
                layout(barmode = "group", 
                       xaxis = list(title = "",
                                    showgrid = FALSE,
                                    showline = FALSE,
                                    showticklabels = FALSE,
                                    zeroline = FALSE,
                                    range = c(0, xmax)),
                       yaxis = list(title = "",
                                    showgrid = FALSE,
                                    showline = FALSE,
                                    zeroline = FALSE,
                                    categoryorder = "array",
                                    categoryarray = rev(c(recode_scheme))),
                       legend = list(traceorder = "reversed",
                                     orientation = 'h'),
                       margin = list(pad = 20)) 
            
            # If a tract is selected, get selected summary and add bars
            add_selected_bars <- function(p){
                if(is_selected){
                    
                    # Format data and add a category column
                    selected_data <- .data %>% 
                        filter(GEOID %in% selected_GEOIDs())
                    
                    selected_data <- selected_data %>%
                        get_pct_table() %>%
                        mutate(level = "Selected Census Tracts")
                    
                    # Add labels for the plotly
                    selected_data <- selected_data %>% 
                        mutate(info_type_label = recode(name, !!!recode_scheme)) %>%
                        mutate(pct_rounded = round(pct, 1)) %>%
                        mutate(plotly_label = str_glue(
                            "In the selected census tracts, {pct_rounded}% of the families
                are {str_to_lower(info_type_label)} "))
                    
                    table_plot_data <- table_plot_data %>% 
                        bind_rows(selected_data)
                    
                    
                    # Render plot 
                    p %>%
                        add_bars(data = table_plot_data %>% filter(level == "Selected Census Tracts"),
                                 x = ~pct, y = ~info_type_label,
                                 marker = list(color = "#FC8D62"),
                                 name = "Selected Census Tracts",
                                 text = ~pct,
                                 texttemplate = "%{x:.1f}%",
                                 insidetextanchor = "end",
                                 textposition = "outside",
                                 textangle = 0,
                                 hovertext = ~plotly_label,
                                 hoverinfo = "text")
                } else {
                    # If no tract is selected, renturn the original plot
                    p
                }
            }
            
            # Render plotly options
            comparison_plot %>%
                # Add selected bars
                add_selected_bars() %>%
                plotly_legend_top_right() %>%
                plotly_disable_zoom() %>%
                plotly_hide_modebar() %>%
                layout(plot_bgcolor = "transparent",
                       paper_bgcolor = "transparent")
            
            
        })
    })
}
