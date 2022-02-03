# Counties Panel


counties_panel <- tabPanel(
    "By County",
    tags$div(class = "main-point",
             "Families in the New Castle County are 
             most likely to receive a voucher"),
    plotlyOutput("number_county"),
    tags$div(class = "select-number",
             # Sidebar with a slider input for number of bins
             radioGroupButtons("selectedNumber", 
                               label = "What about the number of households spending above 50% of household income on rent ?",
                               choices = c("Households spending above 50%" = "50",
                                           "Households spending above 30%" = "30"),
                               selected='30')
    ),
    tags$div(class = "main-point",
             "Families in Sussex County may be facing the most difficulty
             getting Housing Choice Voucher"),
    plotlyOutput("prop_county"),
    tags$div(class = "select-prop",
             # Sidebar with a slider input for number of bins
             radioGroupButtons("selectedProp", 
                               label = "What about the number of households spending above 50% of household income on rent ?",
                               choices = c("Households spending above 50%" = "50",
                                           "Households spending above 30%" = "30"),
                               selected='30')
    )
)
