# Plot proportions across counties

plot_prop_census <- function(perc,ids){
    
    if (perc==30){
        selected_table<-advoc_table %>% 
            mutate_at(vars(GEOID),as.character) %>%
            mutate(selected=ifelse(NAMELSAD %in% ids,"1","0"))%>%
            arrange(`% Spending 30%+ of income on rent`)
        selected_table$GEOID <- factor(selected_table$GEOID, levels = selected_table$GEOID[order(selected_table$`% Spending 30%+ of income on rent`)])
        prop_census_plot <- selected_table %>%
            ggplot(aes(x=GEOID,y=`% Spending 30%+ of income on rent`,group=1,
                       text=paste("GEOID: ",GEOID,
                                  "<br>Census Tract: ",NAME,
                                  "<br>% Spending 30%+ of income on rent: ",`% Spending 30%+ of income on rent`
                                  )))+
            geom_bar(aes(fill=selected),   # fill depends on cond2
                     stat="identity",
                     position=position_dodge())+
            ylab("% Spending 30%+ of income on rent")+
            xlab("")+
            theme(panel.background = element_rect(fill = "white"),
                  legend.position="none",
                  axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank())
    }
    else{
        selected_table<-advoc_table %>% 
            mutate_at(vars(GEOID),as.character) %>%
            mutate(selected=ifelse(NAMELSAD %in% ids,"1","0")) %>%
            arrange(`% Spending 50%+ of income on rent`)
        selected_table$GEOID <- factor(selected_table$GEOID,
                                       levels = selected_table$GEOID[order(selected_table$`% Spending 50%+ of income on rent`)])
        prop_census_plot <- selected_table %>%
            ggplot(aes(x=GEOID,y=`% Spending 50%+ of income on rent`,group=1,
                       text=paste("GEOID: ",GEOID,
                                  "<br>Census Tract: ",NAME,
                                  "<br>% Spending 50%+ of income on rent: ",`% Spending 50%+ of income on rent`
                       )))+
            geom_bar(aes(fill=selected),   # fill depends on cond2
                     stat="identity",
                     position=position_dodge())+
            ylab("% Spending 50%+ of income on rent")+
            xlab("")+
            theme(panel.background = element_rect(fill = "white"),
                  legend.position="none",
                  axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank()) 
        
    }
    
    return(ggplotly(prop_census_plot,tooltip="text"))
}

