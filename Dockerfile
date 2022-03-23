FROM rocker/shiny-verse:4.1.1
RUN install2.r rsconnect leaflet plotly sf shinyWidgets reticulate leaflet.extras
WORKDIR /home/shinyusr
COPY app/ /home/shinyusr/app/
COPY deploy.R deploy.R
CMD Rscript deploy.R
