FROM rocker/shiny-verse
RUN install2.r rsconnect here leaflet plotly sf shinyWidgets
WORKDIR /home/shinyusr
COPY app/ /home/shinyusr/app/
COPY deploy.R deploy.R
CMD Rscript deploy.R
