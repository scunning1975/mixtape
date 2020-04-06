library(tidyverse)
library(haven)

training_bias_reduction <- read_data("training_bias_reduction.dta") %>% 
  mutate(
    Y1 = case_when(Unit %in% c(1,2,3,4) ~ Y),
    Y0 = c(4,0,5,1,4,0,5,1))

train_reg <- lm(Y ~ X, training_bias_reduction)

training_bias_reduction <- training_bias_reduction %>% 
  mutate(u_hat0 = predict(train_reg))
