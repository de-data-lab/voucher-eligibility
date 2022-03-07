# Counties Panel

counties_div <- tags$div(
    tags$div(class = "main-point-container",  
             tags$div(class = "main-heading-container", 
                      tags$div(class = "main-point",
                               "New Castle County has the largest number of
             potentially-eligible families")
             ),
             tags$div(class = "select-threshold plot-title",
                                tags$div("Number of "),
                                selectInput("selectedNumber", 
                                            label = NULL,
                                            choices = c("rent-burdened" = "30",
                                                        "severely rent-burdened" = "50"),
                                            selected = "30",
                                            width = 250),
                                tags$div("families")
             ),
             plotlyOutput("number_county")
    ),
    tags$div(class = "main-point-container",
             tags$div(class = "main-heading-container", 
                      tags$div(class = "main-point",
                               "Sussex County is struggling the most to help
                                Delaware families")
                      ),
             tags$div("Renters Potentially Eligible for Voucher"),
             plotlyOutput("prop_counties"),
             tags$div(class = "select-threshold",
                      radioGroupButtons("selectedProp", 
                                        label = "Focusing on families with rent spending:",
                                        choices = c("30%+ of income" = "30",
                                                    "50%+ of income" = "50"),
                                        selected='30')
                      
             )
    )
)
