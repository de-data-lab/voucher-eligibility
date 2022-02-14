# Counties Panel

counties_div <- tags$div(
    tags$div(class = "main-point",
             "New Castle County has the largest number of
             potentially-eligible families"),
    plotlyOutput("number_county"),
    tags$div(class = "select-threshold",
             radioGroupButtons("selectedNumber", 
                               label = "Focusing on families with rent spending:",
                               choices = c("30%+ of income" = "30",
                                           "50%+ of income" = "50"),
                               selected='30')
    ),
    tags$div(class = "main-point",
             "But, it does the best job serving families than other counties—while Sussex County is struggling to do so"),
    plotlyOutput("prop_counties"),
    tags$div(class = "select-threshold",
             radioGroupButtons("selectedProp", 
                               label = "Focusing on families with rent spending:",
                               choices = c("30%+ of income" = "30",
                                           "50%+ of income" = "50"),
                               selected='30')

    )
)
