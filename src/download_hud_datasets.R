# Download data from HUD

library(tidyverse)
library(here)
library(readxl)

hud_2020_tract_AK_URL <- "https://www.huduser.gov/portal/datasets/pictures/files/TRACT_AK_MN_2020.xlsx"
hud_2020_tract_MO_URL <- "https://www.huduser.gov/portal/datasets/pictures/files/TRACT_MO_WY_2020.xlsx"
hud_2020_tract_AK_filepath <- here("data/raw/", "TRACT_AK_MN_2020.xlsx")
hud_2020_tract_MO_filepath <- here("data/raw/", "TRACT_MO_WY_2020.xlsx")


download.file(hud_2020_tract_AK_URL, hud_2020_tract_AK_filepath)
download.file(hud_2020_tract_MO_URL, hud_2020_tract_MO_filepath)

AK_data <- read_xlsx(hud_2020_tract_AK_filepath)
MO_data <- read_xlsx(hud_2020_tract_MO_filepath)

joined_data <- AK_data %>% 
    bind_rows(MO_data)

# Save file
write_csv(joined_data, here("data/processed/hud_2020_tract_joined.csv"))
write_rds(joined_data, here("data/processed/hud_2020_tract_joined.rds"))
