library(AER)
library(haven)
library(tidyverse)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

card <- read_data("card.dta")

#Define variable 
#(Y1 = Dependent Variable, Y2 = endogenous variable, X1 = exogenous variable, X2 = Instrument)

attach(card)

Y1 <- lwage
Y2 <- educ
X1 <- cbind(exper, black, south, married, smsa)
X2 <- nearc4

#OLS
ols_reg <- lm(Y1 ~ Y2 + X1)
summary(ols_reg)

#2SLS
iv_reg = ivreg(Y1 ~ Y2 + X1 | X1 + X2)
summary(iv_reg)

