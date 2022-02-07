library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

# Load Data
acs_hud_de_geojoined <- read_rds("acs_hud_de_geojoined.rds")
geo_data <- acs_hud_de_geojoined
geo_data_nogeometry <- geo_data %>% 
    st_drop_geometry()

data_county <- geo_data_nogeometry %>%
    filter(number_reported > 0) %>%
    mutate(county = substr(GEOID, 3, 5)) %>%
    mutate(county=replace(county, county=='001', 'Kent')) %>%
    mutate(county=replace(county, county=='003', 'New Castle')) %>%
    mutate(county=replace(county, county=='005', 'Sussex'))  %>%
    rowwise() %>% 
    mutate(above30 = sum(rent_30E, rent_35E, rent_40E,rent_50E),
           above50 = rent_50E) %>%
    group_by(county) %>%
    summarize(reported_HUD = sum(number_reported),
              rent_above30 = sum(above30),
              rent_above50 = sum(above50)) 

# Number of households spending above 30% and 50% of hh_income on rent.
number_county_common_layers <- list(
    geom_bar(aes(fill = Category),
             stat = "identity",
             position = position_dodge()),
    ylab("Number of households"),
    xlab("County"),
    theme_minimal(),
    scale_y_continuous(limits = c(0, 30000)),
    scale_fill_brewer(palette = "Set2", direction = -1),
    coord_flip()
)

number_county_30 <- data_county %>%  
    select(reported_HUD, rent_above30, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 30%+ income on rent' = rent_above30) %>%
    gather(Category, count, -c(county)) %>%
    ggplot(aes(x = county, y = count)) + 
    number_county_common_layers +
    ggtitle("Households Spending 30%+ Income on Rent")

number_county_50 <- data_county %>% 
    select(reported_HUD, rent_above50, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 50%+ income on rent' = rent_above50) %>%
    gather(Category, count, -c(county)) %>%
    ggplot(aes(x = county, y = count))+
    number_county_common_layers +
    ggtitle("Households Spending 50%+ Income on Rent")

# Proportion of households spending above 30% and 50% of hh_income on rent and not receiving assitance.
prop_county_common_layers <- list(
    geom_bar(fill = "#fa9fb5",
             stat = "identity",
             width = 0.3),
    scale_y_continuous(labels = scales::percent,
                       limits = c(0, 1)),
    ylab(""),
    xlab(""),
    theme_minimal(),
    theme(legend.position = "none"),
    coord_flip(),
    ggtitle("Potentialy-Eligible Households Not Receiving Voucher")
)

prop_county_30 <- data_county %>% 
    mutate(rent_above30 = (rent_above30 - reported_HUD) / rent_above30) %>%
    select(county, rent_above30) %>%
    dplyr::rename(
        'Households spending 30%+ income on rent' = rent_above30) %>%
    gather(Category, count, -c(county)) %>%
    ggplot(aes(x = county, y = count)) + 
    prop_county_common_layers

prop_county_50 <- data_county %>%
    mutate(rent_above50 = (rent_above50 - reported_HUD) / rent_above50) %>%
    select(county, rent_above50) %>%
    dplyr::rename(
        'Households spending 50%+ income on rent' = rent_above50
    ) %>%
    gather(Category, count, -c(county)) %>%
    ## na.rm = TRUE ensures all values are NA are taken as 0
    ggplot(aes(x = county,y = count)) +
    prop_county_common_layers

