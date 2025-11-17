library(tidyverse)
library(stats)

smooth_dem0 <- lmb_data %>% 
  filter(democrat == 0) %>% 
  select(score, demvoteshare)
smooth_dem0 <- as_tibble(ksmooth(smooth_dem0$demvoteshare, smooth_dem0$score, 
                                 kernel = "box", bandwidth = 0.1))


smooth_dem1 <- lmb_data %>% 
  filter(democrat == 1) %>% 
  select(score, demvoteshare) %>% 
  na.omit()
smooth_dem1 <- as_tibble(ksmooth(smooth_dem1$demvoteshare, smooth_dem1$score, 
                                 kernel = "box", bandwidth = 0.1))

ggplot() + 
  geom_smooth(aes(x, y), data = smooth_dem0) +
  geom_smooth(aes(x, y), data = smooth_dem1) +
  geom_vline(xintercept = 0.5)
  



