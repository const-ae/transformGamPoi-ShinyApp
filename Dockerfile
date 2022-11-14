FROM rocker/r-ver:4.1.1

# Set maintainer/author label
# Overrides label from base image
LABEL org.opencontainers.image.authors="Constantin Ahlmann-Eltze (constantin.ahlmann@embl.de)"
LABEL org.opencontainers.image.source="https://git.embl.de/ahlmanne/transformGamPoi-ShinyApp"
LABEL org.opencontainers.image.licenses="GPL-3"
LABEL org.opencontainers.image.vendor=""


# Install system libraries
RUN apt update && apt upgrade -y && apt install -y libssl-dev liblzma-dev libbz2-dev libicu-dev libtiff-dev libfftw3-dev libcurl4-openssl-dev libxml2-dev libssh2-1-dev libgit2-dev

# Install renv (https://rstudio.github.io/renv/articles/docker.html)
ENV RENV_VERSION 0.15.5
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /project

# Install R dependencies via renv
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library
RUN R -e "renv::restore()"

# Copy necessary files
COPY text.yaml text.yaml
COPY app.R app.R
COPY data data
COPY src src
COPY www www


# Create user
RUN useradd -m shiny -d /home/shiny

# App on port 6868
EXPOSE 6868


USER shiny
CMD ["R", "-e", "shiny::runApp('/project/app.R', host = '0.0.0.0', port = 6868)"]


