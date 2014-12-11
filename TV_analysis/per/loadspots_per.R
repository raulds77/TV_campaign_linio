library(xlsx)
ibope <- read.xlsx("./per/spots/Data.xlsx",sheetName = "Consolidado")
spotemp <- data.frame(rating = numeric(length(ibope$EMISORA)))
spotemp$channel <- ibope$EMISORA
spotemp$tmstmp <- as.POSIXlt(paste(ibope$DIA,strftime(as.POSIXlt(ibope$HORA), format="%H:%M:%S")),format="%Y-%m-%d %H:%M:%S")
spotemp$rating <- ibope$Rating
spotemp$rating <- as.numeric(sub(",", ".", ibope$Rating, fixed = TRUE))
spotemp$rating[which(spotemp$rating == 0)]<-0.005
spotemp$cost <- ibope$TARIFA.IMPRESA

spotemp$fringe <- factor(ibope$Franja)
spotemp$fringe <- factor(spotemp$fringe, c("Day","Early","Prime","Late","overnight"))
spotemp$duration <- ibope$DUR
spotemp <- spotemp[with(spotemp, order(tmstmp)), ]
spotemp$ncost <- spotemp$cost*30/spotemp$duration
if (country == "mex") spotemp$ncost[which(spotemp$duration == 10)] <- spotemp$ncost[which(spotemp$duration == 10)]/1.25


spot <- spotemp
spot$dtype <- "we"

spot$dtype[which(wday(spot$tmstmp)>1 & wday(spot$tmstmp)<7)]<-"wd"

spot$date <- strftime(spot$tmstmp,"%Y%m%d")