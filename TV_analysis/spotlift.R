## Spot Lift


lift <- rep(0,length(spotmp$rating))
for(t in seq(1:length(vtmp$tmstmp))){
  indsp <- which(spotmp$tmstmp>(vtmp$tmstmp[t]-infl*60) & spotmp$tmstmp<=vtmp$tmstmp[t])
  lift[indsp] <- lift[indsp] + xex[t]*spotmp$rating[indsp]/sum(spotmp$rating[indsp])
}


# Calling example:
## Visits
# print("Spot Lift Visits")
# xex <- vtmp$extra_v
# source('./spotlift.R')
# spotmp$lift_v <- lift