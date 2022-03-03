# Plot the number of eligible vs participatong families across counties
library(shiny)
library(tidyverse)
library(plotly)
library(sf)
library(RColorBrewer)

plot_table_desc <- function(agg_selected,selected){
    # Create by-county table (data object inherited from server.R)
    if(selected){
        info_type<-c("Receiving Vouchers","Spending 30%+ income on rent","Spending 50%+ income on rent")
        tot<-c(0,0,0)
        selected<-c(0,0,0)
        table_df<-data.frame(info_type,tot,selected)
        table_df[1,3] <- round((sum(agg_selected$`# Receiving assisstance`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        table_df[2,3] <- round((sum(agg_selected$`# Spending 30%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        table_df[3,3] <- round((sum(agg_selected$`# Spending 50%+ of income on rent`) / sum(agg_selected$tot_hh)) * 100, digits = 2)
        
        table_df[1,2] <- round((sum(advoc_table$`# Receiving assisstance`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[2,2] <- round((sum(advoc_table$`# Spending 30%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[3,2] <- round((sum(advoc_table$`# Spending 50%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        
        #print(table_df)
        
        table_plot = table_df %>% 
            dplyr::rename(
                'All Census Tracts'=tot,
                'Selected Census Tracts'=selected
            ) %>%
            gather(Category, count, -c(info_type)) %>%
            ## na.rm = TRUE ensures all values are NA are taken as 0
            ggplot(aes(x=info_type,y=count,fill=Category,
                       label = paste(count,"%")))+
            geom_bar(stat="identity",
                     colour="black",    # Black outline for all
                     position=position_dodge())+
            #geom_col(position=position_dodge()) +
            scale_y_continuous(limits = c(0, 15)) +
            geom_text(position=position_dodge(0.9),size=3)+
            scale_fill_brewer(palette = "Set2", direction = -1, name = "")+
            ylab("")+
            xlab("")+
            ggtitle("") +
            coord_flip()+
            theme(panel.background = element_rect(fill = "white"))
    }
    else{
        info_type<-c("Receiving Vouchers","Spending 30%+ income on rent","Spending 50%+ income on rent")
        tot<-c(0,0,0)
        table_df<-data.frame(info_type,tot)
        table_df[1,2] <- round((sum(advoc_table$`# Receiving assisstance`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[2,2] <- round((sum(advoc_table$`# Spending 30%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        table_df[3,2] <- round((sum(advoc_table$`# Spending 50%+ of income on rent`) / sum(advoc_table$tot_hh)) * 100, digits = 2)
        
        table_plot = table_df %>% 
            dplyr::rename(
                'All Census Tracts'=tot
            ) %>%
            gather(Category, count, -c(info_type)) %>%
            ## na.rm = TRUE ensures all values are NA are taken as 0
            ggplot(aes(x=info_type,y=count,fill=Category,
                       label = paste(count,"%")))+
            geom_bar(stat="identity",
                     colour="black",    # Black outline for all
                     position=position_dodge())+
            #geom_col(position=position_dodge()) +
            scale_y_continuous(limits = c(0, 15)) +
            geom_text(position=position_dodge(0.9),size=3)+
            scale_fill_brewer(palette = "Set2", direction = -1, name = "")+
            ylab("")+
            xlab("")+
            ggtitle("") +
            coord_flip()+
            theme(panel.background = element_rect(fill = "white"))
    }
    
    out_plot <- ggplotly(table_plot, tooltip = "") %>%
        format_plotly()
    
    return(out_plot)

    
}

