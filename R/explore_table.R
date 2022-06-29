# Shiny module for the table output on the explore page

explore_table_UI <- function(id) {
    tagList(
        div(class = "advoc-table",
            tableOutput(NS(id, "explore_table"))
        ),
        div(class = "table-footnote",
            downloadButton(NS(id, "downloadData"), "Download")),
        div(class = "down-footnote","(Dowloads data from above table)"),
        div(class = "table-footnote",
            "The number of households appears as 10 when there are 10 or less 
             households in a given cell.",
            br(),
            downloadLink(NS(id, "downloadAll"), "Download All Data"))
    )
}

explore_table_server <- function(id, selected_GEOIDs, .data) {
    moduleServer(id, function(input, output, session) {
        # Render the tale
        output$explore_table <- renderTable({
            .data %>% 
                filter(GEOID %in% selected_GEOIDs()) %>%  
                format_table()
        }, align = "c")
        
        # Download data
        output$downloadData <- downloadHandler(
            filename <- function() {
                paste("voucher_data.csv")
            },
            content = function(file) {
                .data %>% 
                    filter(GEOID %in% selected_GEOIDs()) %>%  
                    format_table() %>% 
                    write_csv(file)
            }
        )
        
        # Download all data
        output$downloadAll <- downloadHandler(
            filename = function() {
                paste("voucher_data_All.csv")
            },
            content = function(file) {
                .data %>%
                    format_table() %>% 
                    write_csv(file)
            }
        )
        
    })
}
