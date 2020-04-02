#Instrumental Variables Chapter
# Feb 2019
# Cunningham


#------------Code 7.1 266 -------------#
#Load Data
library(AER)
library(haven)
library(tidyverse)

card <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/card.dta")

#Define variable 
#(Y1 = Dependent Variable, Y2 = endogenous variable, X1 = exogenous variable, X2 = Intrument)

attach(card)

Y1  <-  lwage
Y2  <-  educ
X1  <-  cbind(exper, black, south, married, smsa)
X2  <-  nearc4

#OLS
ols_reg <- lm(Y1 ~ Y2 + X1)
summary(ols_reg)

#2SLS
iv_reg = ivreg(Y1 ~ Y2 + X1 | X1 + X2)
summary(iv_reg)

