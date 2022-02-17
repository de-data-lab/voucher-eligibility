# Plot proportions across counties

plot_prop_counties <- function(.data){
    prop_counties_data <- .data %>%
        group_by(county_name, labels) %>%
        summarise(count = sum(value, na.rm = TRUE)) %>%
        mutate(prop = count / sum(count))
    
    prop_counties_plot <- prop_counties_data %>%
        ggplot(aes(x = county_name, y = prop, fill = labels,
                   label = paste(scales::percent(prop)))) +
        geom_bar(position = "fill", 
                 stat = "identity",
                 width = 0.7) +
        theme_minimal() +
        geom_text(color = "white") + 
        scale_y_continuous(labels = scales::percent) +
        scale_fill_brewer(palette = "Set2", name = "", direction = -1) + 
        scale_x_discrete(limits = rev(c("New Castle",
                                        "Kent",
                                        "Sussex"))) + 
        ylab("") +
        xlab("") +
        ggtitle("Renters Potentially Eligible for Voucher") +
        coord_flip()
    
    out_plot <- prop_counties_plot %>%
        ggplotly(tooltip = "") %>%
        layout(legend = list(traceorder = "reversed")) %>%
        plotly_legend_top_right() %>%
        plotly_disable_zoom() %>%
        plotly_hide_modebar()
    
    return(out_plot)
}

