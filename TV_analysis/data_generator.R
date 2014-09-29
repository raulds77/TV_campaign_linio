# Data generator: visits, revenues and orders

library(lubridate)
library(bigrquery)
library(httpuv)
library(RMySQL)
library(yaml)

country <- toupper(country)
inicio <- as.Date(start)
final <- as.Date(end)

# - - - - - - - - - - - - - - - #
# Inputs # 
x <- yaml.load_file("keys.yaml") 
# - - - - - - - - - - - - - - - #

if(country == "MEX"){
project <- "ace-amplifier-455" 
dataset <- "58090804"
}

if(country == "COL"){
  project <- "golden-passkey-615"
  dataset <- "58093646"
}

if(country == "PER"){
  project <- "virtual-door-615"
  dataset <- "59608596"
}

seq <- seq(from = inicio, to=final,by = 1)

p1 <- paste("SELECT date, hits.hour,hits.minute, sum(totals.visits) visits, sum(totals.newVisits) newvisits FROM [",project,":",dataset,".ga_sessions_",sep="")
p2 <- "] where trafficSource.medium not like 'CRM%' and trafficSource.source not like 'Hermedia%' and trafficSource.source not like 'Ingenious%' and hits.time = 0 group by date, hits.hour, hits.minute order by date,hits.hour, hits.minute;"

p1_direct <- paste("SELECT date, hits.hour,hits.minute, sum(totals.visits) direct, sum(totals.newVisits) nv_direct FROM [" ,project,":",dataset, ".ga_sessions_",sep="")
p2_direct <- "] where trafficSource.source like '(direct)' and trafficSource.medium not like 'CRM%' and trafficSource.source not like 'Hermedia%' and trafficSource.source not like 'Ingenious%' and hits.time = 0 group by date, hits.hour, hits.minute order by date,hits.hour, hits.minute;"

p1_organic <-paste("SELECT date, hits.hour,hits.minute, sum(totals.visits) organic, sum(totals.newVisits) nv_organic FROM [" ,project,":",dataset, ".ga_sessions_",sep="") 
p2_organic <- "] where trafficSource.medium like 'organic' and trafficSource.medium not like 'CRM%' and trafficSource.source not like 'Hermedia%' and trafficSource.source not like 'Ingenious%' and hits.time = 0 group by date, hits.hour, hits.minute order by date,hits.hour, hits.minute;"

p1_brand <- paste("SELECT date, hits.hour,hits.minute, sum(totals.visits) brand, sum(totals.newVisits) nv_brand FROM [",project,":",dataset,".ga_sessions_",sep="")
p2_brand <- "] where trafficSource.campaign like '%brand%' and trafficSource.medium not like 'CRM%' and trafficSource.source not like 'Hermedia%' and trafficSource.source not like 'Ingenious%' and hits.time = 0 group by date, hits.hour, hits.minute order by date,hits.hour, hits.minute;"

p1_gross_orders <- "select date, hour(time) hits_hour, minute(time) hits_minute, sum(rev) as gross_rev,count(distinct OrderNum) as gross_orders from regional.A_Master where OrderBeforeCan = 1 and date = '"
p2_gross_orders <- paste("' and Country = '",country,"' group by date,hits_hour,hits_minute order by date,hits_hour,hits_minute;",sep="") 

p1_net_orders <- "select date, hour(time) hits_hour, minute(time) hits_minute, sum(rev) as net_rev,count(distinct OrderNum) as net_orders from regional.A_Master where OrderAfterCan = 1 and date = '"
p2_net_orders <- paste("' and Country = '",country,"' group by date,hits_hour,hits_minute order by date,hits_hour,hits_minute;",sep="") 

#Generic data frame
hits_hour <- rep(0:23,each=60)
hits_minute <- rep(c(0:59),24)

for(i in 1:length(seq)){

    fecha <- paste(year(seq[i]),sprintf("%02d",month(seq[i])),sprintf("%02d",day(seq[i])),sep="")
    file <- paste(tolower(country),"/traffic/",tolower(country),"_visits_",fecha,".csv",sep="")
    
    if(!file.exists(file)){
      
        print(paste(fecha,"Begin"))
        
        # Generic data frame
        data_m <- data.frame(hits_hour,hits_minute)
        data_m$date <- as.Date(seq[i])
        
        # Queries
        sql <- paste(p1,fecha,p2,sep="")  
        sql_direct <- paste(p1_direct,fecha,p2_direct,sep="")
        sql_organic <- paste(p1_organic,fecha,p2_organic,sep="")
        sql_brand <- paste(p1_brand,fecha,p2_brand,sep="")
        sql_gross_orders <- paste(p1_gross_orders,seq[i],p2_gross_orders,sep="")
        sql_net_orders <- paste(p1_net_orders,seq[i],p2_net_orders,sep="")
        
        # Bigquery data
        print(paste(fecha,"BigQuery data ..."))
        
        data <- query_exec(project,dataset,query = sql, billing = project)
        data$date <- seq[i]
        
        data_direct <- query_exec(project,dataset,query = sql_direct, billing = project)
        data_direct$date <- seq[i]
        
        data_organic <- query_exec(project,dataset,query = sql_organic, billing = project)
        data_organic$date <- seq[i]
        
        data_brand <- query_exec(project,dataset,query = sql_brand, billing = project)
        data_brand$date <- seq[i]
        # MySQL data
        print(paste(fecha,"MySQL data ..."))
        
        mydb = dbConnect(MySQL(), user=x$user, password=x$password, host=x$host)
        
        data_gross_orders <- dbSendQuery(mydb,sql_gross_orders)
        data_gross_orders <- fetch(data_gross_orders,n=1440) 
        
        data_net_orders <- dbSendQuery(mydb,sql_net_orders)
        data_net_orders <- fetch(data_net_orders,n=1440) 
        
        dbDisconnect(mydb)
        
        # Merge
        print(paste(fecha,"Merging ..."))
        
        data_m <- merge(x = data_m, y = data, by = c("date","hits_hour","hits_minute"), all.x=TRUE)
        data_m <- merge(x = data_m, y = data_direct, by = c("date","hits_hour","hits_minute"), all.x=TRUE)
        data_m <- merge(x = data_m, y = data_organic, by = c("date","hits_hour","hits_minute"), all.x=TRUE)
        data_m <- merge(x = data_m, y = data_brand, by = c("date","hits_hour","hits_minute"), all.x=TRUE)
        data_m <- merge(x = data_m, y = data_gross_orders, by = c("date","hits_hour","hits_minute"), all.x=TRUE)
        data_m <- merge(x = data_m, y = data_net_orders, by = c("date","hits_hour","hits_minute"), all.x=TRUE)

        ### NA's to 0 
        print(paste(fecha,"NA's to 0 ..."))
        names <- names(data_m)
        for (i in 1:ncol(data_m)){          
          if(names[i] != "date"){
            data_m[which(is.na(data_m[,i])),i]<-0
          }
        }
        
        
        # New variables
        data_m$branding <- data_m$direct + data_m$organic + data_m$brand 
        data_m$nv_branding <- data_m$nv_direct + data_m$nv_organic + data_m$nv_brand 
        
        # Write file
        print(paste(fecha,"Writing File ..."))
        write.csv(data_m,file)
        
        print(paste(fecha,"Done"))
    }
}

country <- tolower(country)

suppressWarnings(rm(x,project, dataset, hits_hour, hits_minute, inicio, final, seq, fecha, p1,p1_brand,p1_direct,p1_gross_orders,p1_net_orders,p1_organic,p2,p2_brand,p2_direct,p2_gross_orders,p2_net_orders,p2_organic))
