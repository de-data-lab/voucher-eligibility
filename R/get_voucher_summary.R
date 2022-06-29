# Function to calculate a summary table 
get_voucher_summary <- function(.data, group = "number_not_using_30",
                                by_county = FALSE){
    # Filter data with the specified group
    .data <- .data %>%
        filter(name %in% c(group, "number_reported"))
    
    # Set group 
    # If by_count is true 
    if(by_county) {
        .data <- .data %>%
            group_by(labels, county_name)
    }
    if(!by_county){
        .data <- .data %>%
            group_by(labels)
    }
    
    # Get the summary table
    .data %>%
        summarise(counts = sum(count, na.rm = T)) %>%
        mutate(prop = counts / sum(counts),
               percent = 100 * prop)
}
