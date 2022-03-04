# Plot proportions across counties

str_wrap_br <- function(string, width = 50){
    paste(
        strwrap(string,
                width),
        collapse = "<br>")
}

plot_prop_counties <- function(.data, threshold = "30"){
    
    if(threshold == "30"){
        family_text <- "rent-burdened famillies"
    }
    
    if(threshold == "50"){
        family_text <- "severely rent-burdened famillies"
    }
    
    txt_receiving <- str_wrap_br(
        paste0("In %{y} County, %{x:.1%} of the ", 
               family_text,
               " are receiving a voucher <extra></extra>"),
        width = 30)
    
    txt_not_receiving <- str_wrap_br(
        paste0("In %{y} County, %{x:.1%} of the ", 
               family_text,
               " are not receiving a voucher <extra></extra>"),
        width = 30)
    
    prop_counties_data <- .data %>%
        group_by(county_name, labels) %>%
        summarise(count = sum(value, na.rm = TRUE)) %>%
        mutate(prop = count / sum(count))
    
    prop_counties_plot <- plot_ly() %>% 
        add_bars(data = prop_counties_data %>% filter(labels == "Receiving Voucher"),
                 x = ~prop, y = ~county_name,
                 marker = list(color = "#66C2A5"),
                 name = "Receiving Voucher",
                 text = ~prop,
                 texttemplate = "%{x:.1%}",
                 insidetextanchor = "start",
                 textposition = "inside",
                 textangle = 0,
                 hovertemplate = txt_receiving
        ) %>%
        add_bars(data = prop_counties_data %>% filter(labels == "Not Receiving Voucher"),
                 x = ~prop, y = ~county_name,
                 marker = list(color = "#FC8D62"),
                 name = "Not Receiving Voucher",
                 text = ~prop,
                 texttemplate = "%{x:.1%}",
                 insidetextanchor = "end",
                 textposition = "inside",
                 hovertemplate = txt_not_receiving
        ) %>%
        layout(barmode = "stack",
               xaxis = list(title = "",
                            showgrid = FALSE,
                            showline = FALSE,
                            showticklabels = FALSE,
                            zeroline = FALSE,
                            tickformat = ".2%"),
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
    
    out_plot <- prop_counties_plot 
    
    return(out_plot)
}





