# Plot proportions across counties

plot_prop_census <- function(perc, ids){
    
    # Set colors
    hex_default <- "#66C2A5"
    hex_selected <- "#FC8D62"
    
    if (perc == 30){
        target_var <- sym("% Spending 30%+ of income on rent")
        burden_label <- "rent-burdened"
    } else if (perc == 50){
        target_var <- sym("% Spending 50%+ of income on rent")
        burden_label <- "severely rent-burdened"
    }
    
    selected_table <- advoc_table %>% 
        mutate_at(vars(GEOID), as.character) %>%
        mutate(selected = ifelse(GEOID %in% ids, "1", "0"))
    
    selected_table <- selected_table %>% 
        arrange(!!target_var)
    
    selected_table$GEOID <- factor(selected_table$GEOID,
                                   levels = selected_table$GEOID[order(selected_table[[target_var]])])
    # Calculate z-scores
    selected_table <- selected_table %>% 
        mutate(spending_30 = `% Spending 30%+ of income on rent`,
               spending_50 = `% Spending 50%+ of income on rent`) %>% 
        mutate(across(starts_with("spending"), ~as.vector(scale(.)))) 
    
    overall_average_rounded <- mean(selected_table[[target_var]]) %>% 
        round(1)
    
    # Get the rank of the case that is closest to the mean (to zero)
    average_rank <- which.min(abs(selected_table$spending_30))
    
    average_GOID <- selected_table %>% 
        filter(row_number() == average_rank) %>%
        pull(GEOID)
    
    # Get the max y position 
    max_y <- selected_table[[target_var]] %>% max()
    overall_label_position <- max_y - max_y/4
    selected_label_position <- max_y - max_y/1.5
    
    # Prepare a list of additional geoms for the selected tracts (if none, blank)
    selected_geoms <- list()
    if(length(ids) > 0){
        # Calculate the mean for the selected tracts
        selected_average <- selected_table %>% 
            group_by(selected) %>%
            summarise(mean = mean(!!target_var)) %>%
            filter(selected == "1") %>% 
            pull(mean) %>% unlist()
        selected_average_rounded <- selected_average %>% round(1)
        
        # Get the rank of a tract that has closest to the mean
        selected_average_rank <- which.min(abs(selected_table[[target_var]] - selected_average))

        # Set the label for the selected tracts
        selected_label <- str_glue("In the selected tracts, {selected_average_rounded}% 
                                   of families are {burden_label}") %>% 
            str_wrap(width = 20)
        
        # Prepare a geom to add to the main plot
        selected_geoms <- list(
            geom_vline(xintercept = selected_average_rank,
                       alpha = 0.2, linetype = 3,
                       color = hex_selected),
            annotate("text",
                     label = selected_label,
                     x = selected_average_rank,
                     y = selected_label_position)
        )
    }
    
    
    prop_census_plot <- selected_table %>%
        ggplot(aes(x = GEOID,
                   y = !!target_var,
                   group = 1,
                   text = paste("GEOID: ", GEOID,
                                "<br>Census Tract: ", tract,
                                "<br>", as.character(target_var),": ",
                                !!target_var
                   ))) +
        geom_bar(aes(fill = selected),
                 stat = "identity",
                 position = position_dodge()) +
        geom_vline(xintercept = average_rank,
                   alpha = 0.1, linetype = 2) +
        selected_geoms +
        annotate("text",
                 label = str_wrap(str_glue(
                     "In Delaware, {overall_average_rounded}% of
                              families are {burden_label}"),
                     width = 20),
                 x = average_rank,
                 y = overall_label_position) +
        scale_fill_manual("legend", values = c("1" = hex_selected,
                                               "0" = hex_default)) +
        scale_x_discrete(expand = expansion(mult = .1)) +
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
