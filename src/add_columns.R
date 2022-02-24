library(tidyverse)
library(here)
# Add columns to the joined dataset
acs_hud_de_geojoined <- read_rds(here("data/processed/acs_hud_de_geojoined.rds"))
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(census_tract_label = paste0("Census Tract ", NAME.shape))

# Save to the main project
write_rds(acs_hud_de_geojoined, here("data/processed/acs_hud_de_geojoined.rds"))
# Save to the app
write_rds(acs_hud_de_geojoined, here("app/acs_hud_de_geojoined.rds"))
