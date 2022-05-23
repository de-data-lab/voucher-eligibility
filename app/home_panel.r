# homepage
library(shinyWidgets)
source("counties.R")
home_panel <- tabPanel(
    id = "home",
    title = "Home",
    fluidRow(class = "title-container",
             tags$div(class = "title",
                      "How is Delaware helping families in a housing crisis?"),
             actionLink(inputId = "to_explore_page", 
                        label = "Explore Your Neighborhood",
                        class = "learn-more-button")
    ),
    tags$div(
        class = "main-point-container",
        tags$div(class = "main-heading-container",
                 tags$div(class = "main-point",
                          "Families spending more than 30% of their income on
                          rent are considered", tags$strong("rent-burdened"),
                          "and experiencing a housing crisis"),
                 tags$div(class = "main-point--footnote",
                          "If they are spending more than 50%, they are considered",
                          tags$strong("severely rent-burdened")
                 )
        ),
        tags$div(class = "main-point--icon",
                 icon("heart-broken"))
    ),
    tags$div(
        class = "main-point-container",
        tags$div(class = "main-heading-container",
                 tags$div(class = "main-point",
                          "Housing Choice Voucher (Section 8) provides 
             housing for families in a housing crisis")
        ),
        tags$div(class = "main-point--icon",
                 icon("house-user"))
    ),
    tags$div(class = "main-point-container",
             tags$div(class = "main-heading-container", 
                      tags$div(class = "main-point",
                               "Housing Choice Voucher is an effective way 
             to help families and provide better opportunities")
             ),
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
             tags$div(class = "main-point--icon",
                      icon("hand-holding-heart"))
    ),
    tags$div(class = "main-point-container",
             tags$div(class = "main-heading-container", 
                      tags$div(class = "main-point",
                               textOutput("main_text"))
                      ),
             tags$div(class = "select-county plot-title",
                      tags$div("Rent-burdened families in "),
                      selectInput("selectedCounty", 
                                  label = NULL,
                                  choices = c("Delaware" = "all",
                                              "New Castle County" = "003",
                                              "Kent County" = "001",
                                              "Sussex County" = "005"),
                                  width = "230px")
             ),
             plotlyOutput("mainplot")
    ),
    counties_div, 
    tags$div(class = "main-point-container",
             tags$div(class = "main-heading-container", 
                      tags$div(class = "main-point",
                               "Are you struggling to pay rent?")
             ),
             tags$div(class = "take-action-container",
                      tags$div(class = "take-action-card blue",
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
    ),
    includeHTML("CTA.html"), # Call-to-action section
    fluidRow(
        id = "learn-more-container",
        class = "learn-more--container",
        tags$div(class = "main-point",
                 "Want to learn more about how your neighborhood is doing?"
        ),
        actionLink(inputId = "to_explore_page_bottom", 
                   label = "Explore Your Neighborhood",
                   class = "learn-more-button")
    )
)
