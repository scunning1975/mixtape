library(tidyverse)
library(haven)
library(estimatr)
library(lfe)
library(SteinIV)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

judge <- read_data("judge_fe.dta")

#grouped variable names from the data set
judge_pre <- judge %>% 
  select(starts_with("judge_")) %>% 
  colnames() %>% 
  subset(., . != "judge_pre_8") %>% # remove one for colinearity
  paste(., collapse = " + ")

demo <- judge %>% 
  select(black, age, male, white) %>% 
  colnames() %>% 
  paste(., collapse = " + ")

off <- judge %>% 
  select(fel, mis, sum, F1, F2, F3, M1, M2, M3, M) %>% 
  colnames() %>% 
  paste(., collapse = " + ")

prior <- judge %>% 
  select(priorCases, priorWI5, prior_felChar, 
         prior_guilt, onePrior, threePriors) %>% 
  colnames() %>% 
  paste(., collapse = " + ")

control2 <- judge %>%
  mutate(bailDate = as.numeric(bailDate)) %>% 
  select(day, day2, bailDate, 
         t1, t2, t3, t4, t5) %>% # all but one time period for colinearity
  colnames() %>% 
  paste(., collapse = " + ")

#formulas used in the OLS
min_formula <- as.formula(paste("guilt ~ jail3 + ", control2))
max_formula <- as.formula(paste("guilt ~ jail3 + possess + robbery + DUI1st + drugSell + aggAss",
                                demo, prior, off, control2, sep = " + "))

#max variables and min variables
min_ols <- lm_robust(min_formula, data = judge)
max_ols <- lm_robust(max_formula, data = judge)

#--- Instrumental Variables Estimations
#-- 2sls main results
#- Min and Max Control formulas
min_formula <- as.formula(paste("guilt ~ ", control2, " | 0 | (jail3 ~ 0 +", judge_pre, ")"))
max_formula <- as.formula(paste("guilt ~", demo, "+ possess +", prior, "+ robbery +", 
                                off, "+ DUI1st +", control2, "+ drugSell + aggAss | 0 | (jail3 ~ 0 +", judge_pre, ")"))
#2sls for min and max
min_iv <- felm(min_formula, data = judge)
summary(min_iv)
max_iv <- felm(max_formula, data = judge)
summary(max_iv)



#-- JIVE main results
#- minimum controls
y <- judge %>%
  pull(guilt)

X_min <- judge %>%
  mutate(bailDate = as.numeric(bailDate)) %>%
  select(jail3, day, day2, t1, t2, t3, t4, t5, bailDate) %>%
  model.matrix(data = .,~.)

Z_min <- judge %>%
  mutate(bailDate = as.numeric(bailDate)) %>%
  select(-judge_pre_8) %>%
  select(starts_with("judge_pre"), day, day2, t1, t2, t3, t4, t5, bailDate) %>%
  model.matrix(data = .,~.)

jive.est(y = y, X = X_min, Z = Z_min)

#- maximum controls
X_max <- judge %>%
  mutate(bailDate = as.numeric(bailDate)) %>%
  select(jail3, white, age, male, black,
         possess, robbery, prior_guilt,
         prior_guilt, onePrior, priorWI5, prior_felChar, priorCases,
         DUI1st, drugSell, aggAss, fel, mis, sum,
         threePriors,
         F1, F2, F3,
         M, M1, M2, M3,
         day, day2, bailDate, 
         t1, t2, t3, t4, t5) %>%
  model.matrix(data = .,~.)

Z_max <- judge %>%
  mutate(bailDate = as.numeric(bailDate)) %>%
  select(-judge_pre_8) %>%
  select(starts_with("judge_pre"), white, age, male, black,
         possess, robbery, prior_guilt,
         prior_guilt, onePrior, priorWI5, prior_felChar, priorCases,
         DUI1st, drugSell, aggAss, fel, mis, sum,
         threePriors,
         F1, F2, F3,
         M, M1, M2, M3,
         day, day2, bailDate, 
         t1, t2, t3, t4, t5) %>%
  model.matrix(data = .,~.)

jive.est(y = y, X = X_max, Z = Z_max)
