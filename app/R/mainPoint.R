#' Draw a main point container with a main text, footnote, and an icon
#'
#' @param main_text A list of main text
#' @param footnote A list of footenote
#' @param icon An icon
#'
#' @return A UI definition in the shiny.tag class
#' @export
#'
#' @examples
mainPoint <- function(main_text = list(), footnote = list(), icon = NULL){
    fluidRow(
        class = "main-point-container",
        div(class = "main-heading-container",
            div(class = "main-point", !!!main_text),
            div(class = "main-point--footnote", !!!footnote)
        ),
        div(class = "main-point--icon", icon)
    )
}
