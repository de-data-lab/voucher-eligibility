# Counties Panel

counties_div <- tags$div(
    tags$div(class = "main-point",
             "New Castle County has the largest number of
             potentially-eligible families"),
    plotlyOutput("number_county"),
    tags$div(class = "select-threshold",
             radioGroupButtons("selectedNumber", 
                               label = "Focusing on households with rent spending:",
                               choices = c("30%+ of income" = "30",
                                           "50%+ of income" = "50"),
                               selected='30')
    ),
    tags$div(class = "main-point",
             "But, it does the best job serving families than other counties"),
    tags$div(class = "main-point",
             "On the other hand, families in Sussex County may be facing 
             the most difficulty getting vouchers"),
    plotlyOutput("prop_county"),
    tags$div(class = "select-threshold",
             radioGroupButtons("selectedProp", 
                               label = "Focusing on households with rent spending:",
                               choices = c("30%+ of income" = "30",
                                           "50%+ of income" = "50"),
                               selected='30')
    )
)
