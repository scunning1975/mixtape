lmb_data <- lmb_data %>% 
  mutate(demvoteshare_c = demvoteshare - 0.5)

lm_1 <- lm_robust(score ~ lagdemocrat + demvoteshare_c, data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat + demvoteshare_c, data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat + demvoteshare_c, data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

