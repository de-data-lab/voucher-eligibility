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

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    # Application title
    titlePanel("Housing Choice Voucher Community Efficiency Index"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput("selectedCounty", "Select County",
                        choices = c("New Castle", "Kent", "Sussex"))
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
            leafletOutput("map")
        )
    )
))
