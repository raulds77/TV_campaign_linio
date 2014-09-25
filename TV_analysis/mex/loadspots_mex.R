ibope <- read.csv("./mex/spots/Data_Linio.csv")
spotemp <- data.frame(lift = numeric(length(ibope$Canal)))
spotemp$channel <- ibope$Canal
spotemp$tmstmp <- as.POSIXlt(paste(ibope$Fecha,ibope$Hora),format="%d/%m/%Y %H:%M:%S")
spotemp$rating <- ibope$Rating
spotemp$rating <- as.numeric(sub(",", ".", ibope$Rating, fixed = TRUE))
spotemp$rating[which(spotemp$rating == 0)]<-0.005
spotemp$cost <- ibope$Tarifa
spotemp$cost <- spotemp$cost/13
spotemp$fringe <- ibope$Franja
spotemp$duration <- ibope$Duracion_Spot
spotemp <- spotemp[with(spotemp, order(tmstmp)), ]

spot <- spotemp
spot$dtype <- "we"

for (i in 1:length(spot)){
  if(wday(spot$tmstmp[i])>1 && wday(spot$tmstmp[i])<6) spot$dtype[i]<-"wd" else spot$dtype[i]<-"we"  
}

spot$date <- strftime(spot$tmstmp,"%Y%m%d")