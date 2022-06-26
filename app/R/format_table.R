# A function to format the output table for rendering 
format_table <- function(.data){
    .data %>% 
        select(tract, GEOID, prop_serviced, prop_above30, prop_above50) %>%
        # Mutate for rendering 
        mutate(across(c(prop_serviced, prop_above30, prop_above50),
                      ~sprintf("%.1f%%", .))) %>% 
        # Rename for rendering
        rename("Census Tract" = tract,
               "Receiving assisstance" = prop_serviced,
               "Spending 30%+ income on rent" = prop_above30,
               "Spending 50%+ income on rent" = prop_above50)
}
