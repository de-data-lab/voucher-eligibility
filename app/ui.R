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

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Housing Choice Voucher Community Efficiency Index"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("selectedCounty", 
                        label = "Select County",
                        choices = c("(All Delaware)" = "all",
                                    "New Castle" = "003",
                                    "Kent" = "001",
                                    "Sussex" = "005"))
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            plotlyOutput("mainplot"),
            leafletOutput("map"),
            "We defined renters potentially eligible for housing vouchers by calculating renter households paying 30% or more income on rent."
        )
    )
))
