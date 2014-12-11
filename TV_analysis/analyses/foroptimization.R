### Optimization potential, fast view

goodchans <- which(chtm$eff > 0.05)
badchans <- which(chtm$eff <= 0.05)
effgood <- sum(chtm$eff[goodchans]*chtm$count[goodchans])/sum(chtm$count[goodchans])
effbad <- sum(chtm$eff[badchans]*chtm$count[badchans])/sum(chtm$count[badchans])

invgood <- sum(chtm$ncost[goodchans])
invbad <- sum(chtm$ncost[badchans])

chtm$suggested <- 0
chtm$suggested[goodchans] <- (invgood + invbad)*chtm$eff[goodchans]/sum(chtm$eff[goodchans])

newlift <- sum(chtm$eff*chtm$suggested)
oldlift <- sum(abs(chtm$lift_nv))

newlift/oldlift  ## same investment, times more lift
oldlift/newlift  ## same effect, times less investment
