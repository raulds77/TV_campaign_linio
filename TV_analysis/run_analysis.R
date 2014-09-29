### This is the main script to run the 8 - min analysis and saving the spot lift data


setwd("C:/Users/enrique.balp/Desktop/TV_campaign_linio/TV_analysis")

country <- "mex"
end <- "20140921"
infl <- 8

end <- as.POSIXlt(paste(end,"235900"), format="%Y%m%d %H%M%S")
if(country == 'mex') start <- as.POSIXlt("20140827", format="%Y%m%d")
if(country == 'col') start <- as.POSIXlt("20140825", format="%Y%m%d")
if(country == 'per') start <- as.POSIXlt("20140922", format="%Y%m%d")

# First make sure traffic data are available  ---  ./datagenerator.R
source("./data_generator.R")

# Loads and Preprocess spot data  ---  ./[country]/loadspots_[country].R  
source(paste('./',country,'/loadspots_',country,'.R',sep="")) 

# Primary analysis: loads traffic data, calculates baselines and spot lifts -- ./primary_analysis.R
source("./primary_analysis.R")







