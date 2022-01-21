# Join ACS and HUD data 

library(tidyverse)
hud_de_section8 <- read_rds(here("data/processed/hud_de_section8.rds"))
acs_rent30plus_wide <- read_rds(here("data/processed/acs_rent30plus_de_wide.rds"))

# -4 value is suppressed:
# "-4" = Suppressed (where the cell entry is less than 11 for reported families)"
# Treat the -4's as 10
hud_de_section8 <- hud_de_section8 %>% 
    mutate(number_reported = case_when(number_reported == -4 ~ 10,
                                       TRUE ~ number_reported))

# Join ACS
joined_data <- acs_rent30plus_wide %>%
    inner_join(hud_de_section8, by = c("GEOID" = "code"))

write_rds(joined_data, here("data/processed/acs_hud_de_joined.rds"))
