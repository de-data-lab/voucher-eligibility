# Plot proportions across counties

plot_prop_census <- function(perc,ids){
    
    if (perc==30){
        selected_table<-advoc_table %>% 
            mutate_at(vars(GEOID),as.character) %>%
            mutate(selected=ifelse(NAMELSAD %in% ids,"1","0"))%>%
            arrange(prop_above30)
        prop_census_plot <- selected_table %>%
            ggplot(aes(x=GEOID,y=prop_above30))+
            geom_bar(aes(fill=selected),   # fill depends on cond2
                     stat="identity",
                     position=position_dodge())+
            ylab("Proportion of Households")+
            xlab("GEOID")+
            ggtitle(paste("Proportion of households <br> spending above 30% of income on rent"))
    }
    else{
        selected_table<-advoc_table %>% 
            mutate_at(vars(GEOID),as.character) %>%
        mutate(selected=ifelse(NAMELSAD %in% ids,"1","0")) %>%
            arrange(prop_above50)
        prop_census_plot <- selected_table %>%
            ggplot(aes(x=GEOID,y=prop_above50))+
            geom_bar(aes(fill=selected),   # fill depends on cond2
                     stat="identity",
                     position=position_dodge())+
            ylab("Proportion of Households")+
            xlab("GEOID")+
            ggtitle(paste("Proportion of households <br> spending above 50% of income on rent"))
    }
    
    return(prop_census_plot)
}

