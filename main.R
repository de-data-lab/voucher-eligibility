# This file describes which R scripts should be run in which order
# to rebuild the project processed datasets
library(here)
source(here("src/download_acs_data.R"))
source(here("src/download_hud_datasets.R"))
source(here("src/join_acs_hud.R"))
source(here("src/add_geometry_to_ACS_HUD.R"))
source(here("src/add_columns.R"))
