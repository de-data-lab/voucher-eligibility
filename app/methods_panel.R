# Methods Panel

methods_panel <- tabPanel(
    "Methods",
    tags$div(class = "explore-title-container",
             tags$div(class = "main-point bold",
                      "Methods"),
             tags$div(class = "methods-container",
             "We used data from the following sources", 
             tags$ul(
                 tags$li(
                     tags$a("Census Bureau's 2015-2019 5-year ACS data",
                                    href="https://www.census.gov/programs-surveys/acs",
                                    target="_blank")
                     ),
                 tags$li(
                     tags$a("U.S. Department of Housing and Urban Development's Office (HUD) - 2020 Data",
                            href="https://www.huduser.gov/portal/datasets/assthsg.html",
                            target="_blank")
                 )
             ),
             "We defined households potentially eligible for housing vouchers by 
             calculating renter households paying 30% or more income on rent. We
             also excluded households with gross income exceeding $100,000.",
             tags$p(
             "When calculating aggregates across census tracts, 
             we average the numbers across census tracts. ")
             ),
    
    ),
)

