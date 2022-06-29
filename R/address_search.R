# Address search Shiny module

address_search_UI <- function(id) {
    tagList(
        div(class = "explore-subtitle",
            icon("mouse-pointer"),
            "Select census tracts on the map",
            br(),
            "or",
            br(),
            icon("edit"),
            "Look up a census tract using your address"),
        div(class = "address-input-container",
            shinyWidgets::searchInput(NS(id, "address"), label = NULL, placeholder = "Street Address",
                                      btnSearch = icon("search")),
            div(class = "address-message",
                textOutput(NS(id, "address_message"))))
    )
}

address_search_server <- function(id, selected_GEOIDs) {
    moduleServer(id, function(input, output, session) {
        
        # Reactive value for the message for the address lookup
        address_message <- reactiveVal("Example: \"411 Legislative Ave, Dover, DE\"")
        output$address_message <- renderText({ address_message() })
        
        observe({
            # Try getting the GEOID based on a string, when fails, show an error
            tryCatch(
                {
                    # Use censusxy to geocode one address 
                    matched_address <- cxy_oneline(input$address,
                                                   return = "geographies",
                                                   vintage = "ACS2018_Current")
                    # Get the matched GEOID
                    matched_GEOID <- matched_address$geographies.Census.Tracts.GEOID
                    
                    # Get the census tract name and update the reactive value 
                    matched_tract_name <- matched_address$geographies.Census.Tracts.BASENAME
                    address_message(paste0("Your census tract is: ", matched_tract_name))
                    
                    if(is.null(matched_address)){
                        address_message("No place found. Try formatting your address as: \"411 Legislative Ave, Dover, DE\"")
                        
                    }
                    
                    # Update the selected GEOIDs 
                    current_selected_GEOIDs <- selected_GEOIDs()
                    selected_GEOIDs(unique(matched_GEOID, current_selected_GEOIDs))
                },
                # Show the error message
                error = function(cond){
                    address_message("No place found. Try formatting your address as: \"411 Legislative Ave, Dover, DE\"")
                }
            )
        }) %>%
            # Bind to search
            bindEvent(input$address_search)
        
    })
}
