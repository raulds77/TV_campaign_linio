# Primary analysis: loads traffic data, calculates baselines and spot lifts

seqdays <- seq(start,end,by="day")  
v <- data.frame(visits = numeric())
spot2 <- data.frame(rating = numeric())
#wholebaseprom <- read.csv(paste('./',country,'/traffic/',"baseline_",country,".csv",sep=""))

for (j in 1:length(seqdays)){
  
  d <- seqdays[j]
  print("---")
  print(paste("Loading & Analysing",d,country))
  fileres <- paste("./",country,"/results/",country,"_visits_processed_",strftime(d,format="%Y%m%d"),".csv",sep="")
  
  if (! file.exists(fileres)){
  
  ##  --- Load Data & Preprocess --- ##
    
  print(paste("GA BigQuery",d))
  file <- paste('./',country,'/traffic/',country,"_visits_",strftime(d,format = "%Y%m%d"),".csv",sep="")
  vtmp <- read.csv(file,stringsAsFactors = FALSE, na.strings ="null")
  vtmp$tmstmp <- as.POSIXlt(paste(vtmp$date,vtmp$hits_hour,vtmp$hits_minute), format = "%Y-%m-%d %H %M")
  if(wday(d)>1) wd<-wday(d)-1 else wd<-7
  vtmp$wday<-wd
  #vtmp$baseprom <- wholebaseprom[,(1+wd)]
  
  
  ## --- Ratings per minute  --- ##
  
  print(paste("Ratings per minute",d))
  vtmp$rating <- numeric(length(vtmp$tmstmp))
  spotmp <- spot[which(spot$date == strftime(d,format="%Y%m%d")),]
  for(i in 1:length(spotmp$rating)){
    ind<-which.min(abs(as.numeric(difftime(vtmp$tmstmp,spotmp$tmstmp[i]))))
    vtmp$rating[ind]<-vtmp$rating[ind]+spotmp$rating[i]
  } 
 
  ####   ------    Instant Baselines   -----------    ####

  # Visits
  print("Instant Baseline Visits")
  xv <- vtmp$visits;
  source('./instbaselift.R')
  vtmp$base_v <- base; vtmp$extra_v <- extra
  # New visits
  print("Instant Baseline New Visits")
  vx <- vtmp$newvisits;
  source('./instbaselift.R')
  vtmp$base_nv <- base; vtmp$extra_nv <- extra
  # Branded visits
  print("Instant Baseline Branded Visits")
  vx <- vtmp$brand;
  source('./instbaselift.R')
  vtmp$base_b <- base; vtmp$extra_b <- extra

  ####   ------    END Instant Baselines   -----------    ####       

  write.csv(vtmp, fileres)
  } else {
    vtmp <- read.csv(fileres)
  }

  filespots <- paste("./",country,"/results/",country,"_spots_processed_",strftime(d,format="%Y%m%d"),".csv",sep="")
  if (! file.exists(filespots)){
    spotmp <- spot[which(spot$date == strftime(d,format="%Y%m%d")),]
    
    ####  ------  Spot Lifts  ------  ####
    
    # Visits
    print("Spot Lift Visits")
    xex <- vtmp$extra_v
    source('./spotlift.R')
    spotmp$lift_v <- lift
    
    # New Visits
    print("Spot Lift New Visits")
    xex <- vtmp$extra_nv
    source('./spotlift.R')
    spotmp$lift_nv <- lift
    
    # Branded Visits
    print("Spot Lift Branded Visits")
    xex <- vtmp$extra_b
    source('./spotlift.R')
    spotmp$lift_b <- lift
    
    ####  ------  END Spot Lifts  ------  ####
    
    write.csv(spotmp, filespots)
  } else {
    spotmp <- read.csv(filespots)
  }

  v <- rbind(v,vtmp) 
  spot2 <- rbind(spot2,spotmp)
}

spot <- spot2

suppressWarnings(rm(base,lift,extra,xv,xex,j,bad, goods, ind, indsp, t, wd, spot2,spotemp,spotmp,vtmp,ibope,d,fileres,filespots,file,i,seqdays))
