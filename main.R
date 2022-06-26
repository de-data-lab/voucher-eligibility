# This file describes which R scripts should be run in which order
# to rebuild the project processed datasets
library(here)
source(here("src/download_acs_data.R"))
source(here("src/download_hud_datasets.R"))
source(here("src/join_acs_hud.R"))
source(here("src/add_geometry_to_ACS_HUD.R"))
source(here("src/add_columns.R"))
source(here("src/create_summary_tables.R"))

# Get the geojoined file
acs_hud_de_geojoined <- read_rds(here("data/processed/acs_hud_de_geojoined.rds"))

# Calculate centroids for each census tract
acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
    mutate(centroid = st_centroid(geometry)) %>%
    # Set long and lat
    mutate(lon = map_dbl(centroid, ~.[[1]]),
           lat = map_dbl(centroid, ~.[[2]]))

write_rds(acs_hud_de_geojoined, here("data/processed/acs_hud_de_geojoined.rds"))
write_rds(acs_hud_de_geojoined, here("app/data/acs_hud_de_geojoined.rds"))


acs_hud_de_geojoined_voucher_count_long <- acs_hud_de_geojoined %>%
    create_long_count_table()
write_rds(acs_hud_de_geojoined_voucher_count_long,
          here("app/data/acs_hud_de_geojoined_count_long.rds"))
