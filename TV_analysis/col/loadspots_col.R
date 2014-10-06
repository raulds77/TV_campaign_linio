library(xlsx)
seqdays <- seq(start,end,by="day")
## Load & Preprocess spot data from IBOPE
spot <- data.frame(rating = numeric())
for (i in 1:length(seqdays)){
  d <- seqdays[i]
  print(paste("IBOPE",d))
  file <- paste("./col/spots/col_ibope_",strftime(d,format = "%Y%m%d"),".xlsx",sep="")
  ibope <- read.xlsx(file,1,startRow=2)
  if(length(ibope$X.Canal.)==0) next
  discount <- read.csv(paste("./col/spots/col_discounts.csv",sep=""))
  spotemp <- data.frame(rating = numeric(length(ibope$X.Canal.)))
  spotemp$channel <- ibope$X.Canal.
  spotemp$tmstmp <- ibope$X.Hora.Inicio.
  for(i in 1:length(spotemp$tmstmp)){if(nchar(spotemp$tmstmp[i])<6) spotemp$tmstmp[i] <- paste(0,spotemp$tmstmp[i],sep="")}
  for(i in 1:length(spotemp$tmstmp)){if(nchar(spotemp$tmstmp[i])<6) spotemp$tmstmp[i] <- paste(0,spotemp$tmstmp[i],sep="")}
  spotemp$tmstmp <- as.POSIXlt(paste(ibope$X.Fecha.,spotemp$tmstmp),format="%Y%m%d %H%M%S")
  spotemp$rating <- as.numeric(sub(",", ".", ibope$X.Rating.Ccial, fixed = TRUE))
  wh0 <- which(spotemp$rating == 0)
  spotemp$rating[wh0]<-0.005
  spotemp$cost <- ibope$X.Inversion.
  for(i in 1:length(discount$Channel)){
    c <- gsub(" ","",tolower(discount$Channel[i]))
    whch <- which(gsub(" ","",tolower(spotemp$channel)) == c) 
    spotemp$cost[whch] <- spotemp$cost[whch]*(1-discount$Discount[i])
  }
  spotemp$cost <- spotemp$cost/2  ## from colombian/1000 to USD
  spotemp$duration <- ibope$X.Duracion.
  whch <- which((gsub(" ","",tolower(spotemp$channel)) == "espn")|(gsub(" ","",tolower(spotemp$channel)) == "espn+"))
  spotemp$cost[whch] <- 10 * spotemp$duration[whch] 
  spotemp$fringe <- substr(ibope$X.Franja.,2,2)
  spotemp$dist <- numeric(length(spotemp$tmstmp)) 
  if(wday(d)>1 && wday(d)<7) spotemp$dtype<-"wd" else spotemp$dtype<-"we"
  spotemp <- spotemp[with(spotemp, order(tmstmp)), ]
  #for(i in 2:length(spotemp$dist)){spotemp$dist[i] <- as.numeric(difftime(spotemp$tmstmp[i], spotemp$tmstmp[i-1]))}
  spotemp$date <- strftime(spotemp$tmstmp,"%Y%m%d")
  spotemp$ncost <- spotemp$cost*30/spotemp$duration
  if (country == "mex") spotemp$ncost[which(spotemp$duration == 10)] <- spotemp$ncost[which(spotemp$duration == 10)]/1.25
  
  spot <- rbind(spot,spotemp)
}

suppressWarnings(rm(c,wh0,whch,discount))