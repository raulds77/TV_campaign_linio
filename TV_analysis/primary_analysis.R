# Primary analysis: loads traffic data, calculates baselines and spot lifts

seqdays <- seq(start,end,by="day")  
v <- data.frame(visits = numeric())
spot2 <- data.frame(rating = numeric())
#wholebaseprom <- read.csv(paste('./',country,'/traffic/',"baseline_",country,".csv",sep=""))

for (i in 1:length(seqdays)){
  d <- seqdays[i]
  print(paste("Loading & Analysing",d))
  fileres <- paste("./",country,"/results/",country,"_visits_processed_",strftime(d,format="%Y%m%d"),".csv",sep="")
  if (! file.exists(fileres)){
  
  ## Load & Preprocess visits data from BigQuery
  print(paste("GA BigQuery",d))
  file <- paste('./',country,'/traffic/',country,"_visits_",strftime(d,format = "%Y%m%d"),".csv",sep="")
  vtmp <- read.csv(file,stringsAsFactors = FALSE, na.strings ="null")

  vtmp$tmstmp <- as.POSIXlt(paste(vtmp$date,vtmp$hits_hour,vtmp$hits_minute), format = "%Y-%m-%d %H %M")
  
  if(wday(d)>1) wd<-wday(d)-1 else wd<-7
  vtmp$wday<-wd
#  vtmp$baseprom <- wholebaseprom[,(1+wd)]
  
  print(paste("Ratings per minute",d))
  vtmp$rating <- numeric(length(vtmp$tmstmp))
  spotmp <- spot[which(spot$date == strftime(d,format="%Y%m%d")),]
  for(i in 1:length(spotmp$rating)){
    ind<-which.min(abs(as.numeric(difftime(vtmp$tmstmp,spotmp$tmstmp[i]))))
    vtmp$rating[ind]<-vtmp$rating[ind]+spotmp$rating[i]
  } 
 
  print(paste("Instant Baseline",d))
  vtmp$base <- rep(0,length(vtmp$visits))
  thres_rat <- 0.1; winba <- 5; infl <- 8; goods <- 0;
  for(t in seq(1:length(vtmp$visits))){
    bad <- (sum(vtmp$rating[max(1,t-infl+1):t]*seq(.1,min(t*0.1,infl*0.1),0.1))>thres_rat)  
    if(bad) {
      vtmp$base[t] <- vtmp$base[t-1]
      if(vtmp$base[t]>mean(vtmp$visits[max(1,t-winba):t])) vtmp$base[t] <- vtmp$visits[t]
      goods <- 0
    } else {
      goods <- goods + 1
      goods <- min(winba,goods)
      vtmp$base[t] <- (winba-goods)/winba*mean(vtmp$base[max(1,t-winba):max(1,t-goods)]) + goods/winba*mean(vtmp$visits[max(1,t-goods):(t-1)])  
    }  
  }
  vtmp$extra <- vtmp$visits - vtmp$base
  write.csv(vtmp, fileres)
  } else {
    vtmp <- read.csv(fileres)
  }

  filespots <- paste("./",country,"/results/",country,"_spots_processed_",strftime(d,format="%Y%m%d"),".csv",sep="")
  if (! file.exists(filespots)){
    print(paste("Spot Lift",d))
    spotmp <- spot[which(spot$date == strftime(d,format="%Y%m%d")),]
    spotmp$lift <- rep(0,length(spotmp$rating))
    for(t in seq(1:length(vtmp$tmstmp))){
      indsp <- which(spotmp$tmstmp>(vtmp$tmstmp[t]-infl*60) & spotmp$tmstmp<=vtmp$tmstmp[t])
      spotmp$lift[indsp] <- spotmp$lift[indsp] + vtmp$extra[t]*spotmp$rating[indsp]/sum(spotmp$rating[indsp])
    }
    write.csv(spotmp, filespots)
  } else {
    spotmp <- read.csv(filespots)
  }

  v <- rbind(v,vtmp) 
  spot2 <- rbind(spot2,spotmp)
}

spot <- spot2

suppressWarnings(rm(bad, goods, ind, indsp, t, wd, spot2,spotemp,spotmp,vtmp,ibope,d,fileres,filespots,file,i,seqdays))