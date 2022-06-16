plotCard <- function(main_text, secondary_text, plot_content){
    div(class = "main-point-container",
        div(class = "main-heading-container", 
            div(class = "main-point", main_text)),
        div(class = "select-county plot-title", secondary_text),
        plot_content)
}
