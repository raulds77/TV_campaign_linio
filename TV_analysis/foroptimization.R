goodchans <- which(chan$liftcost > 0.1 & chan$good == 1)
badchans <- which(chan$liftcost <= 0.1  & chan$good == 1)
effgood <- sum(chan$liftcost[goodchans]*chan$count[goodchans])/sum(chan$count[goodchans])
effbad <- sum(chan$liftcost[badchans]*chan$count[badchans])/sum(chan$count[badchans])

invgood <- sum(chan$cost[goodchans])
invbad <- sum(chan$cost[badchans])

####################

goodchans <- which(chan$liftcost > 0.1 & chan$good == 1)
badchans <- which(chan$liftcost <= 0.1  & chan$good == 1)
effgood <- sum(chan$liftcost[goodchans]*chan$count[goodchans])/sum(chan$count[goodchans])
effbad <- sum(chan$liftcost[badchans]*chan$count[badchans])/sum(chan$count[badchans])

invgood <- sum(chan$cost[goodchans])
invbad <- sum(chan$cost[badchans])
