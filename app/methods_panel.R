# Methods Panel

methods_panel <- tabPanel(
    "Methods",
    tags$div(class = "methods-container",
             tags$h1("Methodology"),
             tags$p("We defined households potentially eligible for housing vouchers by 
             calculating renter households paying 30% or more income on rent. We
             also excluded households with gross income exceeding $100,000.")
    )
)

