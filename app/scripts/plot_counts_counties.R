# Plot the number of eligible vs participatong families across counties
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

plot_counts_counties <- function(.data, cutoff){
    # Create by-county table (data object inherited from server.R)
    data_county <- .data %>%
        filter(number_reported > 0) %>%
        mutate(county = substr(GEOID, 3, 5)) %>%
        mutate(county=replace(county, county=='001', 'Kent')) %>%
        mutate(county=replace(county, county=='003', 'New Castle')) %>%
        mutate(county=replace(county, county=='005', 'Sussex'))  %>%
        rowwise() %>% 
        #mutate(above30 = sum(rent_30E, rent_35E, rent_40E,rent_50E),
        #       above50 = rent_50E) %>%
        mutate(above30 = eligible_renters,
               above50 = sum(rent_50_10kE,rent_50_20kE,rent_50_35kE,rent_50_50kE,rent_50_75kE)) %>%
        group_by(county) %>%
        summarize(reported_HUD = sum(number_reported),
                  rent_above30 = sum(above30),
                  rent_above50 = sum(above50)) 
    
    # Determine the labels and data depending on the 30/50 cutoff values
    if(cutoff == 30){
        family_text <- "rent-burdened famillies"
        category_label <- "Spending 30%+ income on rent"
        
        plot_data <- data_county %>%  
            select(reported_HUD, rent_above30, county) %>%
            dplyr::rename(
                'Receiving Voucher' = reported_HUD,
                'Spending 30%+ income on rent' = rent_above30) %>%
            gather(Category, count, -c(county))
        }
    
    if(cutoff == 50){
        family_text <- "severely rent-burdened famillies"
        category_label <- "Spending 50%+ income on rent"
        
        plot_data <- data_county %>% 
            select(reported_HUD, rent_above50, county) %>%
            dplyr::rename(
                'Receiving Voucher' = reported_HUD,
                'Spending 50%+ income on rent' = rent_above50) %>%
            gather(Category, count, -c(county))
    }
    
    # Create the output Plotly plot
    out_plot <- plot_ly() %>%
        add_bars(data = plot_data %>% filter(Category == "Receiving Voucher"),
                 x = ~count, y = ~county,
                 marker = list(color = "#66C2A5"),
                 name = "Receiving Voucher",
                 hovertemplate = str_wrap_br(
                     paste0("In %{y} County, %{x:,} families are receiving a voucher <extra></extra>"),
                     width = 30)) %>%
        add_bars(data = plot_data %>% filter(Category == category_label),
                 x = ~count, y = ~county,
                 marker = list(color = "#FC8D62"),
                 name = str_to_title(family_text),
                 hovertemplate = str_wrap_br(
                     paste0("%{y} County has %{x:,} ", 
                            family_text, " <extra></extra>"),
                     width = 30)) %>% 
        layout(xaxis = list(title = "",
                            showgrid = FALSE,
                            showline = FALSE,
                            showticklabels = TRUE,
                            zeroline = FALSE,
                            tickformat = ",",
                            range = list(0, 30000)),
               yaxis = list(title = "",
                            showgrid = FALSE,
                            showline = FALSE,
                            zeroline = FALSE,
                            categoryorder = "array",
                            categoryarray = rev(c("New Castle", "Kent", "Sussex"))),
               legend = list(traceorder = "normal"),
               margin = list(pad = 15),
               paper_bgcolor = "transparent") %>% 
        format_plotly()
    
    return(out_plot)
}





