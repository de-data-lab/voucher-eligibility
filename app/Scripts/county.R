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
    xlab(""),
    theme_minimal(),
    scale_y_continuous(limits = c(0, 30000)),
    scale_fill_brewer(palette = "Set2", direction = 1, name = ""),
    coord_flip()
)

plotly_legend_top_right <- function(p) {
    layout(p, legend = list(orientation = 'h',
                         yanchor = "top",
                         y = 1.03,
                         xanchor = "right",
                         x = 1))
}

number_county_30_data <- data_county %>%  
    select(reported_HUD, rent_above30, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 30%+ income on rent' = rent_above30) %>%
    gather(Category, count, -c(county))
    
number_county_30 <- number_county_30_data %>%
    ggplot(aes(x = county, y = count)) + 
    number_county_common_layers +
    ggtitle("Households Spending 30%+ Income on Rent")

number_county_30 <- number_county_30 %>%
    ggplotly() %>%
    plotly_legend_top_right()

number_county_50_data <- data_county %>% 
    select(reported_HUD, rent_above50, county) %>%
    dplyr::rename(
        'Receiving Voucher' = reported_HUD,
        'Spending 50%+ income on rent' = rent_above50) %>%
    gather(Category, count, -c(county))

number_county_50 <- number_county_50_data %>%
    ggplot(aes(x = county, y = count))+
    number_county_common_layers +
    ggtitle("Households Spending 50%+ Income on Rent")

number_county_50 <- number_county_50 %>%
    ggplotly() %>%
    plotly_legend_top_right()

# Proportion of households eligible vs participating in the voucher program
# (currently in the main server file)


# Proportion of households spending above 30% and 50% of hh_income on rent and not receiving assitance.
prop_county_common_layers <- list(
    geom_bar(stat = "identity",
             width = 0.3),
    scale_y_continuous(labels = scales::percent,
                       limits = c(0, 1)),
    scale_x_discrete(limits = rev(c("New Castle", "Kent", "Sussex"))),
    scale_fill_manual(values = c("#F27405", "gray")),
    ylab(""),
    xlab(""),
    theme_minimal(),
    theme(legend.position = "none"),
    coord_flip(),
    ggtitle("Potentialy-Eligible Households Not Receiving Voucher")
)

prop_county_data <- data_county %>% 
    mutate(rent_above30_prop = (rent_above30 - reported_HUD) / rent_above30,
           rent_above50_prop = (rent_above50 - reported_HUD) / rent_above50)

# Add fill color 
prop_county_data <- prop_county_data %>%
    mutate(highlighted = case_when(max(rent_above30_prop) == rent_above30_prop ~ "highlighted",
                                  TRUE ~ "none"))

prop_county_30 <- prop_county_data %>%
    ggplot(aes(x = county, y = rent_above30_prop, fill = highlighted)) +
    prop_county_common_layers

prop_county_50 <- prop_county_data %>%
    ggplot(aes(x = county,y = rent_above50_prop, fill = highlighted)) +
    prop_county_common_layers

