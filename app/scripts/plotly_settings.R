# Plotly Settings

# Place the lenged on top right
plotly_legend_top_right <- function(p) {
    layout(p, legend = list(orientation = 'h',
                            yanchor = "top",
                            y = 1.05,
                            xanchor = "right",
                            x = 1))
}


plotly_disable_zoom <- function(p) {
    p %>%
        layout(xaxis = list(fixedrange = TRUE),
               yaxis = list(fixedrange = TRUE))
}
