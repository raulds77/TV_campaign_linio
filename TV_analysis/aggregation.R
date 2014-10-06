### Calculates aggregated data per spot, then call plotit
### needs revision because lift no longer exists (see lift_v, lift_nv, lift_b)
### This is not called from primary analysis (aggregation is to be done in Tableau)

library(plyr)

#spot <- spot[which(spot$date >= 20140925 & spot$date < 20140931),]

print("Channel Aggregation")
chanlift <- aggregate(lift_nv~channel,data=spot,mean)
#chanlift$lift_nv[which(chanlift$lift_nv < 0)]<-0
chancost <- aggregate(cost~channel,data=spot,mean)
chanrat <- aggregate(rating~channel,data=spot,mean)
chanliftsd <-aggregate(lift_nv~channel,data=spot,sd,na.rm=TRUE)
names(chanliftsd) <- c("channel","liftsd")
chan <- merge(chanlift, chancost, by= "channel")
chan <- merge(chan, chanrat, by="channel")
chan <- merge(chan, chanliftsd, by = "channel")
chan$liftcost <- chan$lift_nv/chan$cost
chan$liftgrp <- chan$lift_nv/chan$rating
chan$grpcost <- chan$rating/chan$cost
chan$count <- count(spot, 'channel')$freq
suppressWarnings(chan$conflift <- qt(0.975,df=chan$count-1)*chan$liftsd/sqrt(chan$count))
suppressWarnings(chan$confprop <- chan$lift_nv/(qt(0.975,df=chan$count-1)*chan$liftsd/sqrt(chan$count)))
suppressWarnings(chan$good <- 1/(chan$confprop>1)/(chan$count>4))
rm(chanlift,chancost,chanrat,chanliftsd)

print("Channel-Fringe Aggregation")
chanlift <- aggregate(lift_nv~channel+fringe+dtype,data=spot,mean)
chancost <- aggregate(cost~channel+fringe+dtype,data=spot,mean)
chanrat <- aggregate(rating~channel+fringe+dtype,data=spot,mean)
chtmliftsd <-aggregate(lift_nv~channel+fringe+dtype,data=spot,sd,na.rm=TRUE)
names(chtmliftsd) <- c("channel","fringe","dtype","liftsd")
chtm <- merge(chanlift, chancost, by=c("channel","fringe","dtype"))
chtm <- merge(chtm, chanrat, by=c("channel","fringe","dtype"))
chtm <- merge(chtm, chtmliftsd, by = c("channel","fringe","dtype"))
chtm$count <- count(spot, c('channel','fringe','dtype'))$freq
chtm$fringe <- factor(chtm$fringe)
suppressWarnings(chtm$conf <- (qt(0.975,df=chtm$count-1)*chtm$liftsd/sqrt(chtm$count)))
suppressWarnings(chtm$confprop <- chtm$lift_nv/(qt(0.975,df=chtm$count-1)*chtm$liftsd/sqrt(chtm$count)))
suppressWarnings(chtm$good <- 1/(chtm$confprop>1)/(chtm$count>3))
rm(chanlift,chancost,chanrat,chtmliftsd)


chtm$eff <- chtm$lift_nv/chtm$cost
chtm <- chtm[with(chtm, order(-eff)), ]
res <- chtm[c("channel","fringe","dtype","eff","lift_nv","cost", "count")]
write.csv(res,"perres.csv")


