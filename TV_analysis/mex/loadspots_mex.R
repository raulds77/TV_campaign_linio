ibope <- read.csv("./mex/spots/Data_Linio.csv")
spotemp <- data.frame(rating = numeric(length(ibope$Canal)))
spotemp$channel <- ibope$Canal
spotemp$tmstmp <- as.POSIXlt(paste(gsub(" ","",ibope$fecha),gsub(" ","",ibope$Hora)),format="%d/%m/%Y %H:%M:%S")
spotemp$rating <- ibope$Rating
spotemp$rating <- as.numeric(sub(",", ".", ibope$Rating, fixed = TRUE))
spotemp$rating[which(spotemp$rating == 0)]<-0.005
spotemp$cost <- ibope$Tarifa
spotemp$cost <- spotemp$cost/13
spotemp$fringe <- ibope$Franja
spotemp$duration <- ibope$Duracion_Spot
spotemp <- spotemp[with(spotemp, order(tmstmp)), ]
spotemp$ncost <- spotemp$cost*30/spotemp$duration
if (country == "mex") spotemp$ncost[which(spotemp$duration == 10)] <- spotemp$ncost[which(spotemp$duration == 10)]/1.25


spot <- spotemp
spot$dtype <- "we"

spot$dtype[which(wday(spot$tmstmp)>1 & wday(spot$tmstmp)<7)]<-"wd"

spot$date <- strftime(spot$tmstmp,"%Y%m%d")


