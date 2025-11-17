#using all data (note data used is lmb_data, not lmb_subset)

lm_1 <- lm_robust(score ~ lagdemocrat, data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat, data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat, data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)