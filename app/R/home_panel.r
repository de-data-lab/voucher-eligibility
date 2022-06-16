# Home Panel
library(shinyWidgets)
source("R/main_point.R")
source("R/plot_card.R")
source("R/overview_pie.R")
source("R/families_count_plot.R")
source("R/families_prop_plot.R")

home_panel <- function(){
    tabPanel(
        id = "home",
        title = "Home",
        fluidRow(class = "title-container",
                 div(class = "title",
                     "How is Delaware helping families in a housing crisis?"),
                 actionLink(inputId = "to_explore_page", 
                            label = "Explore Your Neighborhood",
                            class = "learn-more-button")
        ),
        main_point(main_text = list("Families spending more than 30% of their income on rent are considered",
                                   tags$strong("rent-burdened"),
                                   "and experiencing a housing crisis"),
                  footnote = list("If they are spending more than 50%, they are considered",
                                  tags$strong("severely rent-burdened")),
                  icon = icon("heart-broken")),
        main_point(main_text = "Housing Choice Voucher (Section 8) provides housing for families in a housing crisis",
                  icon = icon("house-user")),
        main_point(main_text = "Housing Choice Voucher is an effective way to help families and provide better opportunities",
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
        # Render the pie chart showing the proportion of renters receiving voucher
        overview_pie_UI("overview_pie"),
        families_count_plot_UI("familiesCountPlot"),
        # Render the horizontal bar chart showing the number of families across counties
        families_prop_plot_UI("familiesPropPlot"), 
        # Call to action section
        includeHTML("CTA.html"), 
        # Link to the explore tab
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
}
