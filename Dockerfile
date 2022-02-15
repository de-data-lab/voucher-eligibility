FROM rocker/shiny-verse
RUN install2.r rsconnect leaflet plotly sf shinyWidgets tigris reticulate
RUN apt-get update && apt-get install -y python3-pip
RUN pip3 install censusgeocode
WORKDIR /home/shinyusr
COPY app/ /home/shinyusr/app/
COPY deploy.R deploy.R
CMD Rscript deploy.R
