library(tidyverse)

set.seed(3444)

star_is_born <- tibble(
  beauty = rnorm(2500),
  talent = rnorm(2500),
  score = beauty + talent,
  c85 = quantile(score, .85),
  star = ifelse(score>=c85,1,0)
)

star_is_born %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

star_is_born %>% 
  filter(star == 1) %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

star_is_born %>% 
  filter(star == 0) %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

