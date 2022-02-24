# Add shapes to the joined ACS and HUD dataset
library(tidyverse)
library(sf)
library(here)
source(here("src/get_county.R"))
de_shape <- read_sf(here("data/raw/cb_2018_10_tract_500k/cb_2018_10_tract_500k.shp"))
acs_hud_de_joined <- read_rds(here("data/processed/acs_hud_de_joined.rds"))

acs_hud_de_geojoined <- de_shape %>%
    left_join(acs_hud_de_joined,
             by = "GEOID", suffix = c(".shape", ".acs")) %>%
    mutate(tract = NAME.shape)

# Add county string to data
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(county = get_county(COUNTYFP))

# Save to the main project
write_rds(acs_hud_de_geojoined, here("data/processed/acs_hud_de_geojoined.rds"))
# Save to the app
write_rds(acs_hud_de_geojoined, here("app/acs_hud_de_geojoined.rds"))
