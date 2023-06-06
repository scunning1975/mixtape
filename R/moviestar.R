library(tidyverse)
library(patchwork)

set.seed(3444)

star_is_born <- tibble(
  beauty = rnorm(2500),
  talent = rnorm(2500),
  score = beauty + talent,
  c85 = quantile(score, .85),
  star = ifelse(score>=c85,1,0)
)

p1 = star_is_born %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 1, alpha = 0.5) + xlim(-4, 4) + ylim(-4, 4) + 
  geom_smooth(method = 'lm', se = FALSE) + 
  labs(title = "Everyone")

p2 = star_is_born %>% 
  ggplot(aes(x = talent, y = beauty, color = factor(star))) +
  geom_point(size = 1, alpha = 0.25) + xlim(-4, 4) + ylim(-4, 4) + 
  geom_smooth(method = 'lm', se = FALSE) + 
  labs(title = "Everyone, but different") +
  scale_color_discrete(name = 'Star')

p1 + p2
