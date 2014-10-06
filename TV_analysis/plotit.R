### Plots comming from aggregated data in aggregation.R 
### This is not called from primary_analysis.R (plotting will be done in Tableau)

library(ggplot2)
dayplot <- "20140925"

gtime1 <- as.POSIXlt(paste(dayplot,"010000"),format="%Y%m%d %H%M%S")
gtime2 <- as.POSIXlt(paste(dayplot,"235900"),format="%Y%m%d %H%M%S")

index <- which(as.POSIXlt(v$tmstmp)==gtime1 | as.POSIXlt(v$tmstmp)==gtime2)

gtime<-ggplot(v[index[1]:index[2],], aes(tmstmp)) + 
  
  #geom_line(aes(y = v$base_v[index[1]:index[2]]))+
  #geom_line(aes(y = v$base_nv[index[1]:index[2]]))+
  #geom_line(aes(y = v$base_b[index[1]:index[2]]))+
  
  geom_line(aes(y = visits,color="Total"))+
  geom_line(aes(y = branding,color="Branded"))+
  geom_line(aes(y = newvisits,color="New"))+
  
  geom_line(aes(y = rating*50, colour = "TRPs x 50")) +
  
  ylab("Visits per minute")+
  ggtitle(paste("TRPs & Visits (w/baselines)", toupper(country),dayplot))+
  xlab("Time")


gliftcost <- ggplot(chan, aes(x=channel, y=liftcost, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Lift/Cost by Channel"))
gliftgrp <- ggplot(chan, aes(x=channel, y=liftgrp, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Lift/GRPs by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))
gcostgrp <- ggplot(chan, aes(x=channel, y=cost/rating, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Cost per GRP by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))
glift <- ggplot(chan, aes(x=channel, y=lift_nv, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Avg Lift by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))
gcost <- ggplot(chan, aes(x=channel, y=cost, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Avg Cost by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))
grat <- ggplot(chan, aes(x=channel, y=rating, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Avg Rating by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))
gcount <- ggplot(chan, aes(x=channel, y=count, fill=channel)) + geom_bar(stat="identity") +  
  ggtitle(paste("Count by Channel",strftime(start,format="%b%d"),strftime(end,format="%b%d")))

gbubble1 <- ggplot(chan, aes(cost*count, liftcost, size=count, label=channel)) +
  geom_point(colour="red") +scale_size_area(max_size=20)+geom_text(size=3) +
  xlab("Total Investment USD") + ylab("Efficiency") + ggtitle(paste(toupper(country),"Investment vs Efficiency",strftime(start,format="%b%d"),"-", strftime(end,format="%b%d")))

gbubble2 <- ggplot(chan, aes(liftgrp, liftcost, size=cost*count, label=channel)) +
  geom_point(colour="red") +scale_size_area(max_size=20)+geom_text(size=6) +
  xlab("Affinity") + ylab("Efficiency") + ggtitle(paste(toupper(country),"Affinity vs Efficiency",strftime(start,format="%b%d"),"-", strftime(end,format="%b%d")))

gbubble3 <- ggplot(chan, aes(rating, lift, size=conflift, label=channel)) +
  geom_point(colour="red") +scale_size_area(max_size=20)+geom_text(size=3) +
  xlab("Mean GRPs") + ylab("Mean Lift") + ggtitle(paste(toupper(country),"Avg GRP vs Avg Lift",strftime(start,format="%b%d"),strftime(end,format="%b%d")))

gpoint<-ggplot(chan,aes(chan$count,y=lift/cost,ymin=(lift-conflift)/cost,ymax=(lift+conflift)/cost,label=channel))+
  geom_pointrange()+geom_text(size=3)+xlab("# Spots") + ylab("Lift/Cost")+ggtitle("MEX Lift/Cost vs #Spots (with 95% confidence interval of mean efficiency)")

theme_set(theme_gray(base_size = 18))
stamp <- paste(toupper(country),strftime(start,format="%b%d"),"-", strftime(end,format="%b%d"))

coleff <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = (lift_nv/cost)), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle(paste("Efficiency",stamp))

colcount <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = count), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle("# of Spots")

collift <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = log(lift)), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle("Average Lift")

collift <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = log(lift)), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle("Average Lift")

colconf <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = conf), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle("Statistical Confidence sqrt( Lift / ConfidenceInterval)")

colconfprop <- ggplot(chtm, aes(fringe, channel)) + geom_tile(aes(fill = sqrt(confprop)), colour = "white") +
  scale_fill_gradient(low="red",high="green") + facet_grid(.~dtype) + ggtitle(paste("Statistical Confidence -- (Lift / ConfidenceInterval)",stamp))


#   par(mar = c(5,5,2,5))
#   plot(v$tmstmp, v$rating, ylab = "TRPs per minute", xlab = "Date",type = 'l')
#   par(new = T)
#   plot(v$visits, col = "red", axes = F, xlab = NA, ylab = NA, type = 'l')
#   axis(side = 4, col = "red", col.axis="red")
#   mtext(side = 4, line = 3, "Visits per minute", col="red")
#   title("Mexico TRPs and Visits")
