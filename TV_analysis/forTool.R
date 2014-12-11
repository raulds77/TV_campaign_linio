## Conversion data for Rocket TV tool 


tspot <- data.frame(Index=seq(1:length(spot$channel)))
tspot$Ad <- ifelse(spot$duration==30,"Brand_30sec","Deals_10sec")
tspot$Date <- strftime(spot$tmstmp,format="%m/%d/%Y")
tspot$Hour <- strftime(spot$tmstmp,format="%H")
tspot$Minute <- strftime(spot$tmstmp,format="%M")
tspot$Costs <- spot$cost
tspot$GRP <- spot$rating

lugar <- ifelse(country=="mex" & spot$date>="20140910" & spot$date< "20140924","DF","")
tspot$Channel <- paste(spot$channel,lugar)

write.csv(tspot,"LinioTV_PE2.csv",row.names=FALSE)
