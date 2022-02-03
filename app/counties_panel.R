# Counties Panel


counties_panel <- tabPanel(
    "By County",
    tags$div(class = "main-point",
             "Families in the New Castle County are 
             most likely to receive a voucher"),
    plotlyOutput("number_county"),
    tags$div(class = "main-point",
             "Families in Sussex County may be facing the most difficulty
             getting Housing Choice Voucher"),
    plotlyOutput("prop_county")
)
