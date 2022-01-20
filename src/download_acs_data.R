# Download acs data
library(tidycensus)
library(here)
Sys.getenv("CENSUS_API_KEY")
# Select the columns corresponding to the counts of hte 
# households who are paying 30 percent or more on rent 
# https://censusreporter.org/data/table/?table=B25070&geo_ids=140|04000US10&primary_geo_id=04000US10#valueType|estimate
rent_30plus_vars <- c("B25070_007",
                      "B25070_008",
                      "B25070_009",
                      "B25070_010")
de_rent_30plus <- get_acs(
    geography = "tract", 
    variables = income_vars,
    state = "DE")

de_rent30plus_wide <- de_income %>% 
    select(-moe) %>% 
    pivot_wider(id_cols = c("GEOID", "NAME"),
                values_from = estimate,
                names_from = variable)
# Sum the number
de_rent30plus_wide <- de_rent30plus_wide %>%
    rowwise() %>% 
    mutate(eligible_renters = sum(B25070_007,
                                  B25070_008,
                                  B25070_009,
                                  B25070_010)) %>% 
    ungroup()

# Write out the datasets
write_csv(de_rent30plus_wide, here("data/processed/", "de_rent30plus_wide.csv"))
write_rds(de_rent30plus_wide, here("data/processed/", "de_rent30plus_wide.rds"))

