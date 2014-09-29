library(ggplot2)
dayplot <- "20140923"

gtime1 <- as.POSIXlt(paste(dayplot,"190000"),format="%Y%m%d %H%M%S")
gtime2 <- as.POSIXlt(paste(dayplot,"230000"),format="%Y%m%d %H%M%S")

index <- which(as.POSIXlt(v$tmstmp)==gtime1 | as.POSIXlt(v$tmstmp)==gtime2)


### -------- gtime ------------ ###

gtime<-ggplot(v[index[1]:index[2],], aes(tmstmp)) + 

  geom_line(aes(y = v$base_v[index[1]:index[2]]))+
  geom_line(aes(y = v$base_nv[index[1]:index[2]]))+
  geom_line(aes(y = v$base_b[index[1]:index[2]]))+
  
  geom_line(aes(y = visits,color="Total"))+
  geom_line(aes(y = branding,color="Branded"))+
  geom_line(aes(y = newvisits,color="New"))+
  
  geom_line(aes(y = rating*10, colour = "TRPs x 10")) +
  
  ylab("Visits per minute")+
  ggtitle(paste("TRPs & Visits (w/baselines)", toupper(country),dayplot))+
  xlab("Time")
gtime

### -------- spots ------------ ###

glr <- ggplot(spot, aes(x=rating)) +
  geom_point(aes(y=lift_v,color="Total")) +
  geom_point(aes(y=lift_b,color="Branded")) +
  geom_point(aes(y=lift_nv,color="New"))
glr


glc <- ggplot(spot, aes(x=cost)) +
  geom_point(aes(y=lift_v,color="Total")) +
  geom_point(aes(y=lift_b,color="Branded")) +
  geom_point(aes(y=lift_nv,color="New"))
glc


### ---------- Los picos más grandes ------ ###

s <- spot[with(spot, order(-lift_v)), ]
s10 <- s[1:floor(nrow(s)*0.1),]

s <- s[1:1500,]
v_prop <- sum(s10$lift_v)/sum(s$lift_v)
c_prop <- sum(s10$cost)/sum(s$cost)


glr10 <- ggplot(s10, aes(x=rating)) +
  geom_point(aes(y=lift_v,color="Total")) +
  geom_point(aes(y=lift_b,color="Branded")) +
  geom_point(aes(y=lift_nv,color="New"))
glr10

### ---------  CUMSUM --------###

plot(cumsum(s$lift_v),main="Cumulative Sum in Immediate Visits", xlab="Spots",ylab="Visits")
plot(cumsum(s$cost),main="Cumulative Sum in Investment", xlab="Spots",ylab="Dollars")

v_prop <- sum(s10$lift_v)/sum(s$lift_v)
c_prop <- sum(s10$cost)/sum(s$cost)

v_prop
c_prop


###   ------------   Sumas

sum(spot$lift_v)
sum(spot$lift_nv)
sum(spot$lift_b)
