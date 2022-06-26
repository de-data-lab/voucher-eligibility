# Get the ACS + HUD joined data and create summary tables
create_long_count_table <- function(.data){
    .data %>%
        mutate(number_not_using_30 = eligible_renters - number_reported,
               number_not_using_50 = eligible_renters_50pct - number_reported) %>%
        select(GEOID, COUNTYFP, county_name, 
               number_not_using_30,
               number_not_using_50,
               number_reported) %>%
        pivot_longer(cols = c("number_not_using_30", "number_not_using_50", "number_reported"),
                     values_to = "count") %>%
        mutate(labels = case_when(name %in% c("number_not_using_30", "number_not_using_50") ~ "Not Receiving Voucher",
                                  name == "number_reported" ~ "Receiving Voucher"))
}

create_DE_summary_table <- function(.data){
    .data %>% 
        group_by(labels) %>%
        summarise(counts = sum(value, na.rm = T)) %>%
        mutate(percent = 100 * counts / sum(counts))
}

