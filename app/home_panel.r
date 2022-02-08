# homepage
library(shinyWidgets)
source("counties.R")
home_panel <- tabPanel(
    "Home",
    tags$div(class = "main-point",
             "Housing Choice Voucher in Delaware"),
    tags$div(class = "main-point-sm",
             "Housing Choice Voucher (Section 8) provides 
             housing for families in housing crisis"),
    tags$div(class = "main-point",
             icon("house-user")),
     tags$div(class = "main-point-sm",
             "Housing Choice Voucher is an effective way 
             to help families and provide better opportunities"),
    tags$div(class = "main-point--footnote",
             "(Source: ", 
             tags$a(href = "https://www.cbpp.org/research/housing/housing-choice-voucher-program-oversight-and-review-of-legislative-proposals#_ftn2",
                    target = "_blank",
                    "CBPP, 2018"),
             "; ",
             tags$a(href = "https://www.cbpp.org/research/housing/housing-choice-voucher-program-oversight-and-review-of-legislative-proposals#_ftn2",
                    target = "_blank",
                    "CBPP, 2021"),
             ")"
             ),
    tags$div(class = "main-point-sm",
             textOutput("main_text")),
    plotlyOutput("mainplot"),
    tags$div(class = "select-county",
             # Sidebar with a slider input for number of bins
             radioGroupButtons("selectedCounty", 
                               label = "Explore more by selecting a county:",
                               choices = c("(All Delaware)" = "all",
                                           "New Castle" = "003",
                                           "Kent" = "001",
                                           "Sussex" = "005"))
    ),
    counties_div, 
    tags$div(
        class = "main-point--container",
        tags$div(class = "main-point",
                 "Want to learn more about how your neighboorhod is doing?"
        ),
        tags$div(class = "learn-more-button",
                 "Check out our Housing Voucher Lookup Tool"),
        tags$div(class = "main-point-sm",
                 "Interested in doing something about the housing crisis in Delaware?"
                 )
    ),
    tags$div(class = "take-action-container",
             tags$div(class = "take-action-card",
                      tags$div(class = "call-to-action-text", 
                               "Here are some ways you can take action now"),
                      tags$ul(class = "follow-campaign-list",
                              tags$li("Follow", tags$a("H.O.M.E.S. Campaign", href="https://www.homescampaignde.org/")),
                              tags$li("Send a letter to your local representative to support housing reform bills",
                                      tags$a("(Template by H.O.M.E.S.)", 
                                             href = "https://613b7d3b-0baa-4963-a0d2-2c365bc54f9e.filesusr.com/ugd/7148e3_2400e00b6b70477899b65e347060fdd6.docx?dn=Sample%20Letter%20for%20Bill%20of%20Rights%20for%20Individuals%20Experiencing%20Homelessness%20.docx"),
                              )
                      ),
             )
    ),
    tags$div(class = "main-point",
             "Are you currently paying 30% or more of your household income on rent?"),
    tags$div(class = "take-action-container",
             tags$div(class = "take-action-card-blue",
                      tags$div(class = "call-to-action-text", 
                               "You might qualify for housing assistance"),
                      tags$div(class = "call-to-action-text call-to-action-text-sub",
                               "Get in touch with your local housing authority"),
                      tags$ul(class = "follow-housing-authorities-list",
                              tags$li("Wilminton:",
                                      tags$a("Wilmington Housing Authority",
                                             href="https://whadelaware.org/",
                                             target="_blank")),
                              tags$li("Dover:",
                                      "Dover Housing Authority, (302) 678-1965"),
                              tags$li("Newark:",
                                      tags$a("Newark Housing Authority",
                                             href="https://newarkhousingauthority.net/",
                                             target="_blank")),
                              tags$li("New Castle County (outside Wilmington & Newark):",
                                      tags$a("New Castle County Department of Community Services",
                                             href="https://nccde.org/467/Housing-Choice-Voucher-HCV-Program",
                                             target="_blank")),
                              tags$li("Kent & Sussex Counties:",
                                      tags$a("Delaware State Housing Authority (DSHA)",
                                             href="http://www.destatehousing.com/Renters/renters.php",
                                             target="_blank")),
                      ),
             )
    )
)
