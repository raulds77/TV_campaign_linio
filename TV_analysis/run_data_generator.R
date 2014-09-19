# run_data_generator: data generator parameter and running archive

#setwd("~/TV_campaign_linio/TV_analysis")

library(lubridate)
library(bigrquery)
library(httpuv)
library(RMySQL)
library(yaml)

# - - - - - - - - - - - - - - - #
            # Inputs # 

x <- yaml.load_file("keys.yaml")
country <- "MEX"                    # MEX o COL
inicio <- as.Date("2014-08-27")     # Fecha inicial para descarga de datos
final <- as.Date("2014-08-31")      # Fecha final para descarga de datos

# - - - - - - - - - - - - - - - #
