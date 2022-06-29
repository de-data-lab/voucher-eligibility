# Plot proportions across counties
plot_rank_plot <- function(.data, threshold, selected_GEOIDs){
    # Prepare default values
    selected_average_rounded_pct <- NULL
    # Set colors
    hex_default <- "#66C2A5"
    hex_selected <- "#FC8D62"

    # Set target variable name 
    target_var <- case_when(threshold == "30" ~ "prop_above30",
                            threshold == "50" ~ "prop_above50",
                            threshold == "receiving_voucher" ~ "prop_reported_HUD")
    target_var <- sym(target_var)
    
    # Set burden_label
    burden_label <- case_when(threshold == "30" ~ "rent-burdened",
                              threshold == "50" ~ "severely rent-burdened",
                              threshold == "receiving_voucher" ~ "receiving voucher")
    
    # Label the selected census tracts
    selected_table <- .data %>% 
        mutate(selected = case_when(GEOID %in% selected_GEOIDs ~ "1",
                                    TRUE ~ "0"),
               selected_color = case_when(selected == "1" ~ hex_selected,
                                          selected == "0" ~ hex_default))
    
    # Reorder the table 
    selected_table <- selected_table %>% 
        arrange(!!target_var)
    # Set a factor 
    selected_table <- selected_table %>% 
        mutate(GEOID = fct_reorder(GEOID, !!target_var))
    
    # Drop NAs
    selected_table <- selected_table %>%
        drop_na(!!target_var)
    
    # Calculate the mean
    overall_mean <- selected_table %>%
        summarise(mean = mean(!!target_var, na.rm = TRUE)) %>%
        pull(mean)
    overall_mean_pct <- sprintf("%.1f", overall_mean * 100)

    # Get the rank of the case that is closest to the mean (to zero)
    average_rank <- which.min(abs(selected_table[[target_var]] - overall_mean))
    average_GOID <- selected_table %>% 
        filter(row_number() == average_rank) %>%
        pull(GEOID)
    
    # Get the max y position 
    max_y <- selected_table[[target_var]] %>% max( na.rm = TRUE)
    overall_label_position <- max_y - max_y/4
    selected_label_position <- max_y - max_y/1.5
    
    # Prepare a list of additional geoms for the selected tracts 
    # If no tracts are selected, none.
    add_selected_annotations <- function(p){ p }
    mean_line <- function(){ NULL }
    selected_geoms <- list()
    if(length(selected_GEOIDs) > 0){
        # Calculate the mean for the selected tracts
        selected_average <- selected_table %>% 
            group_by(selected) %>%
            summarise(mean = mean(!!target_var, na.rm = TRUE)) %>%
            filter(selected == "1") %>% 
            pull(mean) %>% unlist()
        selected_average_rounded_pct <- sprintf("%.1f", selected_average * 100)
        
        # Get the rank of a tract that has closest to the mean
        selected_average_rank <- which.min(abs(selected_table[[target_var]] - selected_average))
        
        # Set the label for the selected tracts
        selected_label <- str_glue("In the selected communities, {selected_average_rounded_pct}% 
                                   of families are {burden_label}") %>% 
            str_wrap(width = 20)
        
        # Update the function to add annotations
        add_selected_annotations <- function(p){
            p %>%
                add_annotations(text = selected_label,
                                x = selected_average_rank,
                                y = selected_label_position)
        }
    }
    
    # Prepare a function for drawing a line for the mean 
    mean_line <- function(x , color = "black", opacity = 0.1) {
        list(
            type = "line",
            x0 = x,
            x1 = x,
            yref = "paper",
            y0 = 0,
            y1 = 1,
            line = list(color = color, dash = "dot"),
            opacity = opacity
        )
    }
    
    # Add vertical lines for annotation
    add_vlines <- function(p){
        # Note that the reactive value is NULL by default, but
        # after selecting something it can be a length 0 vector
        if(is.null(selected_GEOIDs) | length(selected_GEOIDs) == 0){
            p %>%
                layout(shapes = mean_line(x = average_rank))
        } else if(length(selected_GEOIDs) > 0){
            p %>%
                layout(shapes = list(mean_line(x = average_rank),
                                     mean_line(x = selected_average_rank,
                                               color = hex_selected,
                                               opacity = 0.5)))
        }
    }
    
    # Construct a formula for the y-variable
    y_formula <- formula(paste0("~", as.character(target_var)))
    
    # Createa hover template for the rank plot
    rank_plote_hovertemplate <- str_wrap_br(
        paste0("%{y:.0%} families are ", burden_label, " in %{text} <extra></extra>"),
        width = 30)
    
    # Create a plotly 
    plot <- selected_table %>%
        plot_ly() %>%
        add_bars(data = selected_table,
                 x = ~GEOID,
                 y = y_formula,
                 text = ~census_tract_label,
                 marker = list(color = ~I(selected_color)),
                 hovertemplate = rank_plote_hovertemplate) %>%
        layout(xaxis = list(title_text = "Census Tract",
                            showgrid = FALSE,
                            showline = FALSE,
                            showticklabels = FALSE,
                            zeroline = FALSE),
               yaxis = list(title_text = "",
                            showgrid = FALSE,
                            showline = FALSE,
                            zeroline = FALSE,
                            categoryorder = "array",
                            tickformat = ".0%"),
               legend = list(traceorder = "normal"),
               showlegend = FALSE,
               margin = list(pad = 15),
               paper_bgcolor = "transparent",
               annotations = list(
                   list(x = average_rank,
                        y = overall_label_position,
                        text = str_wrap(str_glue(
                            "In Delaware, {overall_mean_pct}% of families are {burden_label}"),
                            width = 20),
                        showarrow = FALSE)
               ),
               # Hide the text, only used for tooltips
               uniformtext = list(mode = "hide")) %>%
        add_selected_annotations() %>%
        add_vlines()
    
    list(overall_mean = overall_mean_pct,
         selected_mean = selected_average_rounded_pct,
         plot = plot)
}
