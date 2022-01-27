FROM rocker/shiny-verse
RUN install2.r rsconnect shiny here leaflet plotly tidyverse sf
WORKDIR /home/shinyusr
COPY app/ /home/shinyusr/app/
COPY deploy.R deploy.R
CMD Rscript deploy.R
