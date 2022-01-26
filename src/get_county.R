# Converting the county code in Delaware to County String

get_county <- function(county_code){
    county_list <- c(
        "all" = "All Delaware",
        "001" = "Kent County",
        "003" = "New Castle County",
        "005" = "Sussex County"
    )
    if(!(county_code %in% names(county_list))){ stop("County code is not a Delaware county code")}
    return(county_list[[county_code]])
}

get_county <- Vectorize(get_county)
