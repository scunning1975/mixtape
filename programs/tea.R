library(tidyverse)
library(utils)

correct <- tibble(
  cup   = c(1:8),
  guess = c(1:4,rep(0,4))
)

combo <- correct %$% as_tibble(t(combn(cup, 4))) %>%
  transmute(
    cup_1 = V1, cup_2 = V2,
    cup_3 = V3, cup_4 = V4) %>% 
  mutate(permutation = 1:70) %>%
  crossing(., correct) %>% 
  arrange(permutation, cup) %>% 
  mutate(correct = case_when(cup_1 == 1 & cup_2 == 2 &
                               cup_3 == 3 & cup_4 == 4 ~ 1,
                             TRUE ~ 0))
sum(combo$correct == 1)
p_value <- sum(combo$correct == 1)/nrow(combo)