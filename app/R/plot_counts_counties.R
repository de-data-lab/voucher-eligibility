# Plot the number of eligible vs participatong families across counties
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

plot_counts_counties <- function(.data, cutoff){
    # Create a summary table (one row representing a county)
    data_county <- .data %>%
        filter(number_reported > 0) %>%
        group_by(county_name) %>%
        summarize(number_reported = sum(number_reported),
                  rent_above30 = sum(rent_above30),
                  rent_above50 = sum(rent_above50)) 

    # Determine the labels depending on the 30/50 cutoff values
    if(cutoff == 30){
        family_text <- "rent-burdened famillies"
        category_label <- "Spending 30%+ income on rent"
    }
    if(cutoff == 50){
        family_text <- "severely rent-burdened famillies"
        category_label <- "Spending 50%+ income on rent"
    }
    
    # Construct a long-format data for the plot
    # (one row representing a category-county pair)
    plot_data <- data_county %>% 
        select(number_reported, rent_above30, rent_above50, county_name) %>%
        pivot_longer(cols = c(number_reported, rent_above30, rent_above50),
                     names_to = "category",
                     values_to = "count") %>%
        # Create a column for labeling
        mutate(category_label = recode(category,
                                       "number_reported" = "Receiving Voucher",
                                       "rent_above50" = "Spending 50%+ income on rent",
                                       "rent_above30" = "Spending 30%+ income on rent"))

    # Create the output Plotly plot
    plot_ly() %>%
        add_bars(data = plot_data %>% filter(category_label == "Receiving Voucher"),
                 x = ~count, y = ~county_name,
                 marker = list(color = "#66C2A5"),
                 name = "Receiving Voucher",
                 hovertemplate = str_wrap_br(
                     paste0("In %{y} County, %{x:,} families are receiving a voucher <extra></extra>"),
                     width = 30)) %>%
        add_bars(data = plot_data %>% filter(category_label == category_label),
                 x = ~count, y = ~county_name,
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
}
