library(shiny)
library(tidyverse)
library(plotly)
library(sf)


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
number_county_30 = data_county %>%  select(reported_HUD,rent_above30,county) %>%
  dplyr::rename(
    'Household applied for Section 8 assisstance'=reported_HUD,
    'Household spending above 30% of income on rent'=rent_above30) %>%
  gather(Category, count, -c(county)) %>%
  ## na.rm = TRUE ensures all values are NA are taken as 0
  ggplot(aes(x=county,y=count))+
  geom_bar(aes(fill=Category),   # fill depends on cond2
           stat="identity",
           colour="black",    # Black outline for all
           position=position_dodge())+
  ylab("Number of households")+
  xlab("County")+
  labs(color = "Percentage of hh_income spent on rent")+
  ggtitle("Number of households soending above 30% of household income on rent")

number_county_50 = data_county %>%  select(reported_HUD,rent_above50,county) %>%
  dplyr::rename(
    'Household applied for Section 8 assisstance'=reported_HUD,
    'Household spending above 50% of income on rent'=rent_above50) %>%
  gather(Category, count, -c(county)) %>%
  ## na.rm = TRUE ensures all values are NA are taken as 0
  ggplot(aes(x=county,y=count))+
  geom_bar(aes(fill=Category),   # fill depends on cond2
           stat="identity",
           colour="black",    # Black outline for all
           position=position_dodge())+
  ylab("Number of households")+
  xlab("County")+
  labs(color = "Percentage of hh_income spent on rent")+
  ggtitle("Number of households soending above 50% of household income on rent")

# Proportion of households spending above 30% and 50% of hh_income on rent and not receiving assitance.
prop_county_30 = data_county %>% mutate(rent_above30=(rent_above30-reported_HUD)/rent_above30) %>%
  select(county,rent_above30) %>%
  dplyr::rename(
    'Households spending above 30% of income on rent'=rent_above30) %>%
  gather(Category, count, -c(county)) %>%
  ## na.rm = TRUE ensures all values are NA are taken as 0
  ggplot(aes(x=county,y=count))+
  geom_bar(aes(fill=Category),   # fill depends on cond2
           stat="identity",
           colour="black",    # Black outline for all
           position=position_dodge())+
  ylab("Proportion of households NOT receiving assistance")+
  xlab("County")+
  labs(color = "Percentage of hh_income spent on rent")+
  theme(legend.position="top") +
  ggtitle("")


prop_county_50 = data_county %>% mutate(rent_above50=(rent_above50-reported_HUD)/rent_above50) %>%
  select(county,rent_above50) %>%
  dplyr::rename(
    'Households spending above 50% of income on ren'=rent_above50
  ) %>%
  gather(Category, count, -c(county)) %>%
  ## na.rm = TRUE ensures all values are NA are taken as 0
  ggplot(aes(x=county,y=count))+
  geom_bar(aes(fill=Category),   # fill depends on cond2
           stat="identity",
           colour="black",    # Black outline for all
           position=position_dodge())+
  ylab("Proportion of households NOT receiving assistance")+
  xlab("County")+
  labs(color = "Percentage of hh_income spent on rent")+
  theme(legend.position="top") +
  ggtitle("")