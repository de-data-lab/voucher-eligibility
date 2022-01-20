# Clean HUD Data
library(tidyverse)
library(here)
hud_data <- read_rds(here('data/processed/hud_2020_tract_joined.rds'))

hud_de_section8 <- hud_data %>% 
    filter(str_detect(entities, "DE")) %>%
    filter(program_label == "Housing Choice Vouchers") %>% 
    mutate(GEOID = code)

write_csv(hud_de_section8, here("data/processed/hud_de_section8.csv"))
write_rds(hud_de_section8, here("data/processed/hud_de_section8.rds"))
