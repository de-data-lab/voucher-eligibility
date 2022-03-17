# Plot the number of eligible vs participatong families across counties
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

plot_table_desc <- function(agg_selected,selected){
    # Create by-county table (data object inherited from server.R)
    if(selected){
        info_type <- c("Receiving Vouchers","Spending 30%+ income on rent","Spending 50%+ income on rent")
        tot <- c(0,0,0)
        selected <- c(0,0,0)
        table_df <- data.frame(info_type, tot,selected)
        table_df[1,3] <- round((sum(agg_selected$`# Receiving assisstance`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        table_df[2,3] <- round((sum(agg_selected$`# Spending 30%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        table_df[3,3] <- round((sum(agg_selected$`# Spending 50%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        
        table_df[1,2] <- round((sum(advoc_table$`# Receiving assisstance`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[2,2] <- round((sum(advoc_table$`# Spending 30%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[3,2] <- round((sum(advoc_table$`# Spending 50%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        
        table_plot_data <- table_df %>% 
            dplyr::rename(
                'All Census Tracts'=tot,
                'Selected Census Tracts'=selected
            ) %>%
            gather(Category, count, -c(info_type))
        
        txt_selected <- str_wrap_br(
            paste0("For all selected census tracts, %{x}% of the households %{y} <extra></extra>"),
            width = 30)
        txt_all <- str_wrap_br(
            paste0("For all Delaware census tracts, %{x}% of the households %{y} <extra></extra>"),
            width = 30)
        
        table_plot <- plot_ly() %>% 
            add_bars(data = table_plot_data %>% filter(Category=='All Census Tracts'),
                     x = ~count, y = ~info_type,
                     marker = list(color = "#66C2A5"),
                     name = "All Census Tracts",
                     text = ~count,
                     texttemplate = "%{x}%",
                     insidetextanchor = "end",
                     textposition = "outside",
                     textangle = 0,
                     hovertemplate = txt_all
            ) %>%
            add_bars(data = table_plot_data %>% filter(Category=='Selected Census Tracts'),
                     x = ~count, y = ~info_type,
                     marker = list(color = "#FC8D62"),
                     name = "Selected Census Tracts",
                     text = ~count,
                     texttemplate = "%{x}%",
                     insidetextanchor = "end",
                     textposition = "outside",
                     textangle = 0,
                     hovertemplate = txt_selected
            ) %>%
            layout(barmode = "group",xaxis = list(title = "",
                                showgrid = FALSE,
                                showline = FALSE,
                                showticklabels = FALSE,
                                zeroline = FALSE,
                                tickformat = ".2%"),
                   yaxis = list(title = "",
                                showgrid = FALSE,
                                showline = FALSE,
                                zeroline = FALSE,
                                categoryorder = "array",
                                categoryarray = rev(c("Spending 30%+ income on rent","Spending 50%+ income on rent","Receiving Vouchers"))),
                   legend = list(traceorder = "normal"),
                   margin = list(pad = 20),
                   paper_bgcolor = "transparent") %>% 
            format_plotly()
    }
    else{
        info_type <- c("Receiving Vouchers","Spending 30%+ income on rent","Spending 50%+ income on rent")
        tot <- c(0,0,0)
        table_df <- data.frame(info_type, tot)
        table_df[1,2] <- round((sum(advoc_table$`# Receiving assisstance`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[2,2] <- round((sum(advoc_table$`# Spending 30%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[3,2] <- round((sum(advoc_table$`# Spending 50%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        
        table_plot_data <- table_df %>% 
            dplyr::rename(
                'All Census Tracts'= tot
            ) %>%
            gather(Category, count, -c(info_type)) #%>%
        
        txt_all <- str_wrap_br(
            paste0("For all Delaware census tracts, %{x}% of the households %{y} <extra></extra>"),
            width = 30)
            
        table_plot <- plot_ly() %>% 
            add_bars(data = table_plot_data %>% filter(Category=='All Census Tracts'),
                     x = ~count, y = ~info_type,
                     marker = list(color = "#66C2A5"),
                     name = "All Census Tracts",
                     text = ~count,
                     texttemplate = "%{x}%",
                     insidetextanchor = "end",
                     textposition = "outside",
                     textangle = 0,
                     hovertemplate = txt_all
            ) %>%
            layout(barmode = "group",xaxis = list(title = "",
                                                  showgrid = FALSE,
                                                  showline = FALSE,
                                                  showticklabels = FALSE,
                                                  zeroline = FALSE,
                                                  tickformat = ".2%"),
                   yaxis = list(title = "",
                                showgrid = FALSE,
                                showline = FALSE,
                                zeroline = FALSE,
                                categoryorder = "array",
                                categoryarray = rev(c("Spending 30%+ income on rent","Spending 50%+ income on rent","Receiving Vouchers"))),
                   legend = list(traceorder = "normal"),
                   margin = list(pad = 20),
                   paper_bgcolor = "transparent") %>% 
            format_plotly()
    }

    return(table_plot)
}

