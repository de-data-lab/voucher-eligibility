#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(plotly)



shinyUI(navbarPage(
    "Housing Choice Voucher in Delaware",
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    tabPanel("Home",
             tags$div(class = "main-point",
                      textOutput("main_text")),
             plotlyOutput("mainplot"),
             tags$div(class = "select-county",
                      # Sidebar with a slider input for number of bins
                      selectInput("selectedCounty", 
                                  label = "Explore more by selecting a county:",
                                  choices = c("(All Delaware)" = "all",
                                              "New Castle" = "003",
                                              "Kent" = "001",
                                              "Sussex" = "005"))
             ),
             tags$div(class = "main-point",
                      "Do you think that's ok?"),
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
             )
    ),
    tabPanel("Details",
             leafletOutput("map"),
             "We defined renters potentially eligible for housing vouchers by calculating renter households paying 30% or more income on rent."
    ),
    footer = tags$div(class = "footer",
                      includeHTML("footer.html"))
))

