# BigQuery-R connection

# https://github.com/hadley/bigrquery
# Instalar Rtools
devtools::install_github("assertthat")
devtools::install_github("bigrquery")

library(bigrquery)
library(httpuv)

project <- "ace-amplifier-455" # put your projectID here
dataset <- "58090804"
sql <- "SELECT date, hits.hour,hits.minute, sum(totals.visits) visits, sum(totals.newVisits) newvisits, sum(totals.transactions) transactions 
FROM [58090804.ga_sessions_20140714] 
where trafficSource.source not like 'Postal%' and hits.time = 0 
group by date, hits.hour, hits.minute 
order by date,hits.hour, hits.minute;" 

data <- query_exec(project,dataset,query = sql, billing = project)


