# Join ACS and HUD data 

library(tidyverse)
library(here)
hud_de_section8 <- read_rds(here("data/processed/hud_de_section8.rds"))
acs_rent30plus_wide <- read_rds(here("data/processed/acs_rent30plus_de_wide.rds"))

# -4 value is suppressed:
# "-4" = Suppressed (where the cell entry is less than 11 for reported families)"
# Treat the -4's as 10
hud_de_section8 <- hud_de_section8 %>% 
    mutate(number_reported_raw = number_reported) %>% # Retain the original values
    mutate(number_reported = case_when(number_reported == -4 ~ 10,
                                       TRUE ~ number_reported))

# Join ACS
joined_data <- acs_rent30plus_wide %>%
    left_join(hud_de_section8, by = c("GEOID" = "GEOID"))

# Calculate the proportion of the serviced renters vs eligible renters
joined_data <- joined_data %>%
    mutate(prop_serviced = number_reported / eligible_renters)

write_rds(joined_data, here("data/processed/acs_hud_de_joined.rds"))
