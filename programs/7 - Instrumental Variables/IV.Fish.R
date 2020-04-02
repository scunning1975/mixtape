#Instrumental Variables Chapter
# Feb 2019
# Cunningham

#------------Code 7.2 268 -------------#
#Load Data
library(AER)
library(haven)
library(tidyverse)

fish <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/fish.dta")

#Log 
fish <- fish %>% 
  mutate(log_price = log(price), log_quantity = log(quantity))

#Define variable 
#(Y1 = Dependent Variable, Y2 = endogenous variable, X1 = exogenous variable, X2 = Intrument)

attach(fish)

Y1 <- log_quantity
Y2 <- log_price
X1 <- cbind(mon, tues, wed, thurs, time)
X2 <- speed2
X2_alt <- wave2

#OLS
ols_reg <- lm(Y1 ~ Y2 + X1)
summary(ols_reg)

#2SLS
iv_reg1 <- ivreg(Y1 ~ Y2 + X1 | X1 + X2)
summary(iv_reg1)

iv_reg2 <- ivreg(Y1 ~ Y2 + X1 | X1 + X2_alt)
summary(iv_reg2)
