lmb_data %>% 
  filter(demvoteshare > .45 & demvoteshare < .55) %>%
  mutate(demvoteshare_sq = demvoteshare_c^2)

lm_1 <- lm_robust(score ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_2 <- lm_robust(score ~ democrat*demvoteshare_c + democrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)
lm_3 <- lm_robust(democrat ~ lagdemocrat*demvoteshare_c + lagdemocrat*demvoteshare_sq, 
                  data = lmb_data, clusters = id)

summary(lm_1)
summary(lm_2)
summary(lm_3)

