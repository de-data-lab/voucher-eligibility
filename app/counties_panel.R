# Counties Panel


counties_panel <- tabPanel(
    "By County",
    tags$div(class = "main-point",
             "Families in the New Castle County are 
             most likely to receive a voucher"),
    tags$div(class = "comment",
             "(*Add Visual: Number of households spending above 30% and 50%
             of hh_income on rent.)"),
    tags$div(class = "main-point",
             "Families in Sussex County may be facing the most difficulty
             getting Housing Choice Voucher"),
    tags$div(class = "comment",
             "(*Add visual: # Proportion of households spending above 
             30% and 50% of hh_income on rent and not receiving assitance.")
)
