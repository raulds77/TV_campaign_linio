ibope <- read.csv("./per/spots/Data.csv")
spotemp <- data.frame(rating = numeric(length(ibope$EMISORA)))
spotemp$channel <- ibope$EMISORA
spotemp$tmstmp <- as.POSIXlt(paste(ibope$DIA,ibope$HORA),format="%d/%m/%Y %H:%M:%S")
spotemp$rating <- ibope$Rating
spotemp$rating <- as.numeric(sub(",", ".", ibope$Rating, fixed = TRUE))
spotemp$rating[which(spotemp$rating == 0)]<-0.005
spotemp$cost <- ibope$COSTO

spotemp$fringe <- factor(ibope$Franja)
spotemp$duration <- ibope$DUR
spotemp <- spotemp[with(spotemp, order(tmstmp)), ]
spotemp$ncost <- spotemp$cost*30/spotemp$duration
if (country == "mex") spotemp$ncost[which(spotemp$duration == 10)] <- spotemp$ncost[which(spotemp$duration == 10)]/1.25


spot <- spotemp
spot$dtype <- "we"

spot$dtype[which(wday(spot$tmstmp)>1 & wday(spot$tmstmp)<6)]<-"wd"

spot$date <- strftime(spot$tmstmp,"%Y%m%d")