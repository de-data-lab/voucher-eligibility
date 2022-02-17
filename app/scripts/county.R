library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

# Create by-county table (data object inherited from server.R)
data_county <- geo_data_nogeometry %>%
    filter(number_reported > 0) %>%
    mutate(county = substr(GEOID, 3, 5)) %>%
    mutate(county=replace(county, county=='001', 'Kent')) %>%
    mutate(county=replace(county, county=='003', 'New Castle')) %>%
    mutate(county=replace(county, county=='005', 'Sussex'))  %>%
    rowwise() %>% 
    #mutate(above30 = sum(rent_30E, rent_35E, rent_40E,rent_50E),
    #       above50 = rent_50E) %>%
    mutate(above30 = eligible_renters,
           above50 = sum(rent_50_10kE,rent_50_20kE,rent_50_35kE,rent_50_50kE,rent_50_75kE)) %>%
    group_by(county) %>%
    summarize(reported_HUD = sum(number_reported),
              rent_above30 = sum(above30),
              rent_above50 = sum(above50)) 

# Number of households spending above 30% and 50% of hh_income on rent.
number_county_common_layers <- list(
    geom_bar(aes(fill = Category),
             stat = "identity",
             position = position_dodge()),
    ylab("Number of families"),
    xlab(""),
    theme_minimal(),
    scale_x_discrete(limits = rev(c("New Castle", "Kent", "Sussex"))),
    scale_y_continuous(limits = c(0, 30000)),
    scale_fill_brewer(palette = "Set2", direction = 1, name = ""),
    coord_flip()
)


number_county_30_data <- data_county %>%  
    select(reported_HUD, rent_above30, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 30%+ income on rent' = rent_above30) %>%
    gather(Category, count, -c(county))
    
number_county_30 <- number_county_30_data %>%
    mutate("Eligible Families" = count) %>%
    ggplot(aes(x = county, y = `Eligible Families`)) + 
    number_county_common_layers +
    ggtitle("Families Spending 30%+ Income on Rent")

number_county_50_data <- data_county %>% 
    select(reported_HUD, rent_above50, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 50%+ income on rent' = rent_above50) %>%
    gather(Category, count, -c(county))

number_county_50 <- number_county_50_data %>%
    mutate("Eligible Families" = count) %>%
    ggplot(aes(x = county, y = `Eligible Families`)) +
    number_county_common_layers +
    ggtitle("Families Spending 50%+ Income on Rent")

