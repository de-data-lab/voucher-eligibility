#' Get a summary table of percentages from a wide dataset 
#' 
#' `get_pct_table` gets a summary table of percentages of rent-burdened,
#'  severely rent-burdened, and voucher participants from the total households
#'
#' @param .data A wide-format data frame representing one row per census tract. 
#' The data frame needs to have the columns: "number_reported", "rent_above30", 
#' "rent_above50", and "tot_hh"
#'
#' @return A summary table of percentages (pct) and proportions (prop).
#' One row represents a household category (rent-burdened, severely burdened, and voucher participants)
#'
#' @examples 
#' acs_hud_de_geojoined %>%
#'  st_drop_geometry() %>%
#'  get_pct_table()
#' 
#' @export
#'  
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
