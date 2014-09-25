#Instant Baseline and Lift

## Calling example:
# Visits
# print("Instant Baseline Visits")
# vx <- vtmp$visits;
# source('./instbaselift.R')
# vtmp$base_v <- base; vtmp$extra_v <- extra

base <- rep(0,length(xv))
thres_rat <- 0.1; winba <- 5; infl <- 8; goods <- 0;
for(t in seq(1:length(xv))){
  bad <- (sum(vtmp$rating[max(1,t-infl+1):t]*seq(.1,min(t*0.1,infl*0.1),0.1))>thres_rat)  
  if(bad) {
    base[t] <- base[t-1]
    if(base[t]>mean(xv[max(1,t-winba):t])) base[t] <- xv[t]
    goods <- 0
  } else {
    goods <- goods + 1
    goods <- min(winba,goods)
    base[t] <- (winba-goods)/winba*mean(base[max(1,t-winba):max(1,t-goods)]) + goods/winba*mean(xv[max(1,t-goods):(t-1)])  
  }  
}
extra <- xv - base

