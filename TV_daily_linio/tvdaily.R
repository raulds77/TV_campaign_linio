library(lubridate)
library(xlsx)
library(ggplot2)
library(plyr)
setwd("C:/Users/enrique.balp/Desktop/TV_daily_linio/")

country = "mex"

start <- switch(country,col="20140825",mex="20140827")
start <- as.POSIXlt(start, format="%Y%m%d",tz="UTC")

data <- read.xlsx("TVDailyData.xlsx",sheetName=country)
data$date <- as.POSIXlt(data$date, format="%Y-%m-%d",tz="UTC")
data$wd <- wday(data$date)   # -1; data$wd[which(data$wd==0)]<-7
data <- data[which(data$include == 1),]

### Baselines
hist <- data[data$date < start ,5:ncol(data)]
base <- round(aggregate(.~wd,FUN=mean,data=hist),0)
  
### Incremental

camp <- data[data$date>= start,]
baseline <- camp
baseline[,2:4]<-0
for (i in 1:nrow(baseline)){
  bwd <- base[baseline$wd[i],2:ncol(base)] 
  baseline[i,5:(ncol(baseline)-1)] <- bwd
}

incr <- camp - baseline
totalincr <-  colSums(incr[,2:(ncol(incr)-1)],na.rm=TRUE)
relincr <- totalincr[4:length(totalincr)] / colSums(baseline[,5:(ncol(baseline)-1)],na.rm=TRUE)

export <- data.frame(increase = totalincr, relative = c(0,0,0,relincr))

lastdate <- strftime(data$date[length((data$date))],format="%Y%m%d")
#write.xlsx(export, file = paste("increase_",lastdate,".xlsx",sep=""),sheetName=country,append=TRUE)

### So we have now: totalincr, relincr, camp , baseline, incr  (along with data and base)

#barplot(relincr, las=2, main = "Relative increase vs Baseline (Whole Campaing)", ylab="%")
