# Plot proportions across counties

plot_prop_census <- function(perc, ids){
    
    if (perc == 30){
        target_var <- sym("% Spending 30%+ of income on rent")
    } else if (perc == 50){
        target_var <- sym("% Spending 50%+ of income on rent")
    }
    
    selected_table <- advoc_table %>% 
        mutate_at(vars(GEOID), as.character) %>%
        mutate(selected = ifelse(GEOID %in% ids, "1", "0"))
    
    selected_table <- selected_table %>% 
        arrange(!!target_var)
    
    selected_table$GEOID <- factor(selected_table$GEOID,
                                   levels = selected_table$GEOID[order(selected_table[target_var])])
    
    prop_census_plot <- selected_table %>%
        ggplot(aes(x = GEOID,
                   y = !!target_var,
                   group = 1,
                   text = paste("GEOID: ", GEOID,
                                "<br>Census Tract: ", tract,
                                "<br>% Spending 30%+ of income on rent: ",
                                !!target_var
                   ))) +
        geom_bar(aes(fill = selected),
                 stat = "identity",
                 position = position_dodge())+ 
        scale_fill_manual("legend", values = c("1" = "#FC8D62", "0" = "#66C2A5")) +
        ylab(as.character(target_var))+
        xlab("")+
        theme(panel.background = element_rect(fill = "white"),
              legend.position = "none",
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank())
    
    out_plot <- ggplotly(prop_census_plot, tooltip="text") %>%
        format_plotly()
    
    return(out_plot)
}

