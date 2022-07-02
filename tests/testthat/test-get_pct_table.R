test_that("expected output matches with given data", {
    test_data <- dplyr::tibble(GEOID = c("10003013904", "10003014907", "10005050403", 
                                         "10005050101", "10003013608"),
                               number_reported = c(10, 25, 10, NA, 10), 
                               rent_above30 = c(559, 99, 112, 84, 126),
                               rent_above50 = c(226, 49, 29, 71, 90), 
                               tot_hh = c(3208, 1838, 1268, 1430, 721))
    
    expected_results <- dplyr::tibble(
        name = c("number_reported", "rent_above30", "rent_above50"),
        prop = c(0.006497341996456, 0.115770821027761, 0.0549320732427643),
        pct = c(0.6497341996456, 11.5770821027761, 5.49320732427643))
    
    expect_equal(get_pct_table(test_data), expected_results)
})


test_that("percent columns have values from 0 - 100", {
    test_data <- dplyr::tibble(GEOID = c("10003013904", "10003014907", "10005050403", 
                                         "10005050101", "10003013608"),
                               number_reported = c(10, 25, 10, NA, 10), 
                               rent_above30 = c(559, 99, 112, 84, 126),
                               rent_above50 = c(226, 49, 29, 71, 90), 
                               tot_hh = c(3208, 1838, 1268, 1430, 721))
    
    pct <- get_pct_table(test_data)$pct
    
    lapply(pct, expect_gt, expected = 0)
    lapply(pct, expect_lt, expected = 100)
})

test_that("proportion values range from 0 - 1", {
    test_data <- dplyr::tibble(GEOID = c("10003013904", "10003014907", "10005050403", 
                                         "10005050101", "10003013608"),
                               number_reported = c(10, 25, 10, NA, 10), 
                               rent_above30 = c(559, 99, 112, 84, 126),
                               rent_above50 = c(226, 49, 29, 71, 90), 
                               tot_hh = c(3208, 1838, 1268, 1430, 721))
    
    prop <- get_pct_table(test_data)$prop
    
    lapply(prop, expect_gt, expected = 0)
    lapply(prop, expect_lt, expected = 1)
})

test_that("fail if input is a character", {
    expect_error(get_pct_table("a"))
})
