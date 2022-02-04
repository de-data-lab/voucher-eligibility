# Download acs data
library(tidyverse)
library(tidycensus)
library(here)
Sys.getenv("CENSUS_API_KEY")
# Select the columns corresponding to the counts of hte 
# households who are paying 30 percent or more on rent 
# https://censusreporter.org/data/table/?table=B25070&geo_ids=140|04000US10&primary_geo_id=04000US10#valueType|estimate
rent_30plus_vars <- c(rent_30='B25070_007',
                      rent_35='B25070_008',
                      rent_40='B25070_009',
                      rent_50='B25070_010')

# Get Rent Categories x Household Income Table (B25074)
# For each income category and percentage rent spend on household income:
# (10k = less than 10k, 20k = less than 20k, 35k = less than 35k, 50k = less than, and 75k = less than 75k)
rent_10k_vars <- c(rent_30_10k = 'B25074_006',
                   rent_35_10k = 'B25074_007',
                   rent_40_10k = 'B25074_008',
                   rent_50_10k = 'B25074_009',
                   rent_30_20k = 'B25074_015',
                   rent_35_20k = 'B25074_016',
                   rent_40_20k = 'B25074_017',
                   rent_50_20k = 'B25074_018',
                   rent_30_35k = 'B25074_024',
                   rent_35_35k = 'B25074_025',
                   rent_40_35k = 'B25074_026',
                   rent_50_35k = 'B25074_027',
                   rent_30_50k = 'B25074_033',
                   rent_35_50k = 'B25074_034',
                   rent_40_50k = 'B25074_035',
                   rent_50_50k = 'B25074_036',
                   rent_30_75k = 'B25074_042',
                   rent_35_75k = 'B25074_043',
                   rent_40_75k = 'B25074_044',
                   rent_50_75k = 'B25074_045')

rent_variables <- c(med_rent = 'B25031_001',
                    no_bed = 'B25031_002',
                    one_bed = 'B25031_003',    
                    med_rent_perc = 'B25071_001',
                    two_bed = 'B25031_004',
                    three_bed = 'B25031_005',
                    four_bed = 'B25031_006',
                    five_bed = 'B25031_007')

all_census_vars <- c(rent_30plus_vars,
                     rent_10k_vars,
                     rent_variables)

# Get all ACS data in one query
acs_data_joined <- get_acs(
        geography = "tract", 
        variables = all_census_vars,
        state = "DE",
        output = "wide")


# Calculate the potentially-eligible renters
rent_10k_vars_estimates <- paste0(names(rent_10k_vars), "E")
acs_data_joined <- acs_data_joined %>%
    rowwise() %>% 
    mutate(eligible_old = sum(c_across(paste0(names(rent_30plus_vars), "E"))),
           eligible_renters = sum(c_across(rent_10k_vars_estimates))) %>% 
    ungroup()

# Check if the elgiibility change changed the dataset
acs_data_joined %>% 
    ggplot(aes(x = eligible_old, y = eligible_renters)) +
    geom_point() +
    ylab("Excluding Households Earning $100k+") +
    xlab("All Households") + 
    ggtitle("Households Spending 30%+ Income on Rent by DE Census Tracts")
sum(acs_data_joined$eligible_old)
sum(acs_data_joined$eligible_renters)
# We had 500 households in difference by excluding those with 100k+ income


# Write out the dataset
write_csv(acs_data_joined, here("data/processed/", "acs_rent30plus_de_wide.csv"))
write_rds(acs_data_joined, here("data/processed/", "acs_rent30plus_de_wide.rds"))



