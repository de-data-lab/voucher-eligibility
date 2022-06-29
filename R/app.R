#' App
#'
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
#' 
#' 


de_voucher_app <- function(...) {
    
    # Load Data
    acs_hud_de_geojoined <- acs_hud_de_geojoined %>%
        sf::st_transform('+proj=longlat +datum=WGS84')
    geo_data_nogeometry <- acs_hud_de_geojoined %>%
        sf::st_drop_geometry()
    
    ## Count long data
    acs_hud_de_count_long <- acs_hud_de_geojoined_count_long %>%
        sf::st_drop_geometry()
    
    # function to go to the lookup tool
    goto_explore_tab <- function(session){
        updateNavbarPage(session, inputId = "main_page", selected = "Explore Your Neighborhood")
    }
    
    # Define the path to CSS
    path_to_CSS <- system.file("app", "www", "style.css",
                               package = "housingVoucherDelaware")
    print(path_to_CSS)
    
    ui <- navbarPage(
            id = "main_page",
            title = "Housing Choice Voucher in Delaware",
            header = tags$head(
                tags$link(rel = "stylesheet", type = "text/css",
                          href = path_to_CSS)
            ),
            home_panel(), # Add a tab panel for home
            explore_panel(),
            methods_panel(),
            footer = div(class = "footer",
                         includeHTML("footer.html"),
                         tags$script(src = "show_logo.js"))
        )
    

    # Define server logic required to draw a histogram
    server <- function(input, output, session) {
            # Reactive values
            # Vector of selected GEOIDs
            selected_GEOIDs <- reactiveVal()

            # Observe the URL parameter and route the page to an appropriate tab
            observe({
                query <- parseQueryString(session$clientData$url_search)
                query1 <- paste(names(query), query, sep = "=", collapse=", ")
                if(query1 == "page=explore"){
                    goto_explore_tab(session)
                }
            })

            # Server function to draw the pie chart
            overview_pie_server("overview_pie", acs_hud_de_geojoined_count_long)
            # Server function for the families count plot
            families_count_plot_server("familiesCountPlot", geo_data_nogeometry)
            # Server function for the families prop plot
            familiesPropPlotServer("familiesPropPlot", acs_hud_de_count_long)

            # Server function for the explore map
            map_server("explore", selected_GEOIDs, acs_hud_de_geojoined)
            # Server function for the rank plot
            rank_plot_server("rank_plot", selected_GEOIDs, acs_hud_de_geojoined)
            # Server function for the compare-to-DE plot
            compare_to_de_plot_server("compare_to_de", selected_GEOIDs, geo_data_nogeometry)
            # Server function for the address search
            address_search_server("address_search", selected_GEOIDs)
            # Server functions for the explore tables
            explore_table_server("explore_table", selected_GEOIDs, geo_data_nogeometry)

            # Observe the click to the explore page
            observeEvent(input$to_explore_page, {
                goto_explore_tab(session)
            })
            observeEvent(input$to_explore_page_bottom, {
                goto_explore_tab(session)
            })

            # Observe for the clicking the "Clear All" button
            observe({
                selected_GEOIDs(NULL)
            }) %>%
                bindEvent(input$clear)
    }
    
    shinyApp(ui, server)
    

}


