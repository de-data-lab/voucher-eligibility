select_rent_burden <- function(id,
                             selectInputId = "threshold",
                             prefix = div("Number of "),
                             suffix = div("families")){
    tagList(
        prefix,
        selectInput(NS(id, selectInputId), 
                    label = NULL,
                    choices = c("Rent-burdened" = "30",
                                "Severely rent-burdened" = "50"),
                    selected = "30",
                    width = 250),
        suffix
    )
}
