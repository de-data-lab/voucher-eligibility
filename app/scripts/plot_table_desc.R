# Plot the number of eligible vs participatong families across counties
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

# Function to get the data shaped for plotly
to_plotly_data <- function(.data){
    # If no tracts are selected, return all Delaware 
    .data <- .data %>% 
        group_by() %>%
        summarise(across(
            c(receiving = `# Receiving assisstance`,
              spending_30 = `# Spending 30%+ of income on rent`,
              spending_50 = `# Spending 50%+ of income on rent`,
              tot_hh),
            ~sum(.)
        ))
    
    # Get the percentage and drop the total counts
    .data <- .data %>%
        mutate(across(-tot_hh,
                      ~(. / tot_hh))) %>%
        select(-tot_hh)
    
    # Round the percentage 
    .data <- .data %>%
        mutate(across(.fns = ~round(. * 100, 2)))
    
    # Pivot to a long format
    .data <- .data %>%
        pivot_longer(everything(), names_to = "info_type", values_to = "pct")
    
    return(.data)
}

recode_scheme <- c("receiving" = "Receiving Voucher",
                   "spending_30" = "Spending 30%+ of income on rent",
                   "spending_50" = "Spending 50%+ of income on rent")

plot_table_desc <- function(agg_selected, is_selected){
    # Prepare a table for All Delaware
    # If no tracts are selected, return all Delaware 
    all_delaware_data <- to_plotly_data(advoc_table)
    
    # Add a category column indicating the grouping level
    all_delaware_data <- all_delaware_data %>% 
        mutate(category = "All Census Tracts")
    
    # Add labels for the plotly
    all_delaware_data <- all_delaware_data %>% 
        mutate(info_type_label = recode(info_type, !!!recode_scheme)) %>%
        mutate(plotly_label = str_glue(
            "In all Delaware, {pct}% of the families
                are {str_to_lower(info_type_label)} "))
    
    # If no plot is selected, get the all Delaware
    table_plot_data <- all_delaware_data
    

    if (is_selected){
        # Format data and add a category column
        selected_data <- to_plotly_data(agg_selected) %>% 
            mutate(category = "Selected Census Tracts")
        
        # Add labels for the plotly
        selected_data <- selected_data %>% 
            mutate(info_type_label = recode(info_type, !!!recode_scheme)) %>%
            mutate(plotly_label = str_glue(
                "In the selected census tracts, {pct}% of the families
                are {str_to_lower(info_type_label)} "))
        
        table_plot_data <- all_delaware_data %>% 
            bind_rows(selected_data)
    }
    
    # Insert line breaks to the plotly label
    table_plot_data <- table_plot_data %>% 
        rowwise() %>%
        mutate(plotly_label = str_wrap_br(plotly_label, width = 50)) %>%
        ungroup()

    # For both conditions, we need All Delaware bars
    table_plot <- plot_ly() %>% 
        add_bars(data = table_plot_data %>% filter(category == 'All Census Tracts'),
                 x = ~pct, y = ~info_type_label,
                 marker = list(color = "#66C2A5"),
                 name = "All Census Tracts",
                 text = ~pct,
                 texttemplate = "%{x}%",
                 insidetextanchor = "end",
                 textposition = "outside",
                 textangle = 0,
                 hovertext = ~plotly_label,
                 hoverinfo = "text")
    
    # If a tract is selected, add selected bars
    if(is_selected){
        table_plot <- table_plot %>%
            add_bars(data = table_plot_data %>% filter(category == 'Selected Census Tracts'),
                     x = ~pct, y = ~info_type_label,
                     marker = list(color = "#FC8D62"),
                     name = "Selected Census Tracts",
                     text = ~pct,
                     texttemplate = "%{x}%",
                     insidetextanchor = "end",
                     textposition = "outside",
                     textangle = 0,
                     hovertext = ~plotly_label,
                     hoverinfo = "text")
    }
    
    # Calculate the maximum value of x axis, used for calculating x range
    xmax <- max(table_plot_data$pct) * 1.50
    
    # Update layouting
    table_plot <- table_plot %>%
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
                                categoryarray = rev(c("Spending 30%+ income on rent",
                                                      "Spending 50%+ income on rent",
                                                      "Receiving Vouchers"))),
                   legend = list(traceorder = "reversed",
                                 orientation = 'h'),
                   margin = list(pad = 20)) %>% 
            format_plotly()

    return(table_plot)
}
