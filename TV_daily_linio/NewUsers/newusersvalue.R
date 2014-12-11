library("xlsx")
setwd("C:/Users/enrique.balp/Desktop/TV_daily_linio/NewUsers/")
data <- read.xlsx("NewUsers_Rev.xlsx", sheetName="CO")

csR <- cumsum(data$Revenue)
csN <- cumsum(data$New.Users)
#csS <- cumsum(data$Sessions)
#csO <- cumsum(data$Transactions)

start <-300
end <- length(csR)

x <- csN[start:end]
y <- csR[start:end]

fit <- lm(y ~ x)

plot(y ~ x,, ylab="Cummulative Revenue", xlab="Cummulative ")
abline(fit, col='red',lwd = 2)
print(paste("Revenue per New User (local$):",round((fit$coeff[2]),2)))
