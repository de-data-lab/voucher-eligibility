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
                                            choices = c("Rent-burdened" = "30",
                                                        "Severely rent-burdened" = "50"),
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
             tags$div(class = "select-threshold plot-title",
                      selectInput("selectedProp", 
                                  label = NULL,
                                  choices = c("Rent-burdened" = "30",
                                              "Severely rent-burdened" = "50"),
                                  selected = "30",
                                  width = 250),
                      tags$div("families")
             ),
             plotlyOutput("prop_counties")
    )
)
