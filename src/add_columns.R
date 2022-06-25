library(tidyverse)
library(here)
# Add columns to the joined dataset
acs_hud_de_geojoined <- read_rds(here("data/processed/acs_hud_de_geojoined.rds"))
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(census_tract_label = paste0("Census Tract ", NAME.shape))

# Arrange the census tracts by the tract 
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    arrange(as.numeric(tract))

# Create a custom table
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    # Create a sum of eligible renters
    rowwise() %>%
    mutate(rent_above30 = eligible_renters,
           rent_above50 = sum(rent_50_10kE, rent_50_20kE, rent_50_35kE, rent_50_50kE, rent_50_75kE),
           reported_HUD = number_reported,
           tot_hh = tot_hhE) %>%
    ungroup()

# Calculate the proportion of renters under each categories
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(prop_above30 = rent_above30 / tot_hh,
           prop_above50 = rent_above50 / tot_hh,
           prop_reported_HUD = (reported_HUD / tot_hh)) %>%
    # calculate percents 
    mutate(across(c(prop_above30, prop_above50, prop_reported_HUD),
                  .fns = ~. * 100,
                  .names = "pct_{.col}"))

# Dictionary of counties and keys
county_list <- c(
    "all" = "Delaware",
    "001" = "Kent County",
    "003" = "New Castle County",
    "005" = "Sussex County")

# Update the county names
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(county_name = str_remove(recode(COUNTYFP, !!!county_list),
                                    " County"))


# Save to the main project
write_rds(acs_hud_de_geojoined, here("data/processed/acs_hud_de_geojoined.rds"))
# Save to the app
write_rds(acs_hud_de_geojoined, here("app/data/acs_hud_de_geojoined.rds"))
