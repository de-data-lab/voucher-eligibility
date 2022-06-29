# Get the table showing the percentage of the rent-burdened, 
# severely rent-burdened, and receiving voucher groups
# The resulting output will be a summary table where
# one row represents a category

#' Get a summary table of rent-burdened, severely rent-burdened, and voucher participant groups.
#'
#' @param .data 
#'
#' @return
#' @export
#'
#' @examples
get_pct_table <- function(.data){
    # Summarize across variables
    .data <- .data %>% 
        group_by() %>%
        summarise(across(
            c(number_reported,
              rent_above30,
              rent_above50,
              tot_hh),
            ~sum(., na.rm = TRUE)
        ))
    # Get the percentage and drop the total counts
    .data <- .data %>%
        mutate(across(-tot_hh, ~(. / tot_hh))) %>%
        select(-tot_hh)
    # Pivot to create a table where one row represents a level-type pair
    .data %>%
        pivot_longer(everything(), values_to = "prop") %>%
        mutate(pct = prop * 100)
}
