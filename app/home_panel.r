# homepage
library(shinyWidgets)
source("counties.R")
source("R/mainPoint.R")

home_panel <- tabPanel(
    id = "home",
    title = "Home",
    fluidRow(class = "title-container",
             div(class = "title",
                 "How is Delaware helping families in a housing crisis?"),
             actionLink(inputId = "to_explore_page", 
                        label = "Explore Your Neighborhood",
                        class = "learn-more-button")
    ),
    mainPoint(main_text = list("Families spending more than 30% of their income on rent are considered",
                               tags$strong("rent-burdened"),
                               "and experiencing a housing crisis"),
              footnote = list("If they are spending more than 50%, they are considered",
                              tags$strong("severely rent-burdened")),
              icon = icon("heart-broken")),
    mainPoint(main_text = "Housing Choice Voucher (Section 8) provides housing for families in a housing crisis",
              icon = icon("house-user")),
    mainPoint(main_text = "Housing Choice Voucher is an effective way to help families and provide better opportunities",
              footnote = list("(Source: ", 
                              a(href = "https://www.cbpp.org/research/housing/housing-choice-voucher-program-oversight-and-review-of-legislative-proposals#_ftn2",
                                target = "_blank",
                                "CBPP, 2018"),
                              "; ",
                              a(href = "https://www.cbpp.org/research/housing/housing-choice-voucher-program-oversight-and-review-of-legislative-proposals#_ftn2",
                                target = "_blank",
                                "CBPP, 2021"),
                              ")"),
              icon = icon("hand-holding-heart")),
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
