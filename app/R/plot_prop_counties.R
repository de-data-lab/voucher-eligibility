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
        # Get 30% rows 
        .data <- .data %>%
            get_voucher_summary("number_not_using_30",
                                by_county = TRUE)
    }
    
    if(threshold == "50"){
        family_text <- "severely rent-burdened famillies"
        # Get 50% rows
        .data <- .data %>%
            get_voucher_summary("number_not_using_50",
                                by_county = TRUE)
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
    
    # Get the proportions within
    .data <- .data %>%
        group_by(county_name) %>%
        mutate(prop = counts / sum(counts),
               percent = prop * 100)
    
    
    plot_ly() %>% 
        add_bars(data = .data %>% filter(labels == "Receiving Voucher"),
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
        add_bars(data = .data %>% filter(labels == "Not Receiving Voucher"),
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
}





