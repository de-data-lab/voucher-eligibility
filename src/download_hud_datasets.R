# Download data from HUD

library(tidyverse)
library(here)

hud_2020_tract_AK_URL <- "https://www.huduser.gov/portal/datasets/pictures/files/TRACT_AK_MN_2020.xlsx"
hud_2020_tract_MO_URL <- "https://www.huduser.gov/portal/datasets/pictures/files/TRACT_MO_WY_2020.xlsx"

download.file(hud_2020_tract_AK_URL,
              here("data/raw/TRACT_AK_MN_2020.xlsx"))
download.file(hud_2020_tract_MO_URL,
              here("data/raw/TRACT_MO_WY_2020.xlsx"))

