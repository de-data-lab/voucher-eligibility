# This file describes which R scripts should be run in which order
# to rebuild the project processed datasets
library(here)
source(here("src/download_acs_data.R"))
source(here("src/download_hud_datasets.R"))
source(here("src/join_acs_hud.R"))
source(here("src/add_geometry_to_ACS_HUD.R"))
source(here("src/add_columns.R"))
source(here("src/create_summary_tables.R"))


acs_hud_de_geojoined <- read_rds(here("data/processed/acs_hud_de_geojoined.rds"))
DE_summary_receiving_voucher <- acs_hud_de_geojoined %>% 
    st_drop_geometry() %>%
    create_DE_summary_table() 


write_rds(DE_summary_receiving_voucher, 
          here("app/data/acs_hud_de_geojoined_summary.rds"))


acs_hud_de_geojoined_voucher_count_long <- acs_hud_de_geojoined %>%
    create_long_count_table()
write_rds(acs_hud_de_geojoined_voucher_count_long,
          here("app/data/acs_hud_de_geojoined_count_long.rds"))
