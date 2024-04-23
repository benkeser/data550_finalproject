FROM rocker/r-ubuntu as base 

RUN apt-get update
RUN apt-get install -y pandoc

RUN apt-get install -y r-base
RUN apt-get install -y libcurl4-openssl-dev
RUN apt-get install -y libglpk40


RUN mkdir /project
WORKDIR /project

# make renv directory and copy all contensts
RUN mkdir -p renv
COPY renv.lock renv.lock
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

RUN mkdir renv/.cache 
ENV RENV_PATHS_CACHE renv/.cache

RUN R -e "renv::restore()"


#RUN Rscript -e "BiocManager::install('BSgenome.Mmusculus.UCSC.mm10')"
#RUN Rscript -e "install.packages('here')"
###### DO NOT EDIT STAGE 1 BUILD LINES ABOVE ######

FROM rocker/r-ubuntu
WORKDIR /project
COPY --from=base /project .

COPY Makefile .
COPY finalproject_report.Rmd .

RUN mkdir /code
RUN mkdir /output
RUN mkdir /output/figures
RUN mkdir /data
RUN mkdir /report

# Copy over raw data
COPY data/seurat.rds data/seurat.rds

# Copy over code
COPY code/01_SCT_Analysis.R code/01_SCT_Analysis.R
COPY code/02_ATAC_Analysis.R code/02_ATAC_Analysis.R
COPY code/03_render_report.R code/03_render_report.R

CMD make finalproject_report.html report