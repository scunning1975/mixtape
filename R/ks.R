library(tidyverse)
library(stats)

tb <- tibble(
  d = c(rep(0, 20), rep(1, 20)),
  y = c(0.22, -0.87, -2.39, -1.79, 0.37, -1.54, 
        1.28, -0.31, -0.74, 1.72, 
        0.38, -0.17, -0.62, -1.10, 0.30, 
        0.15, 2.30, 0.19, -0.50, -0.9,
        -5.13, -2.19, 2.43, -3.83, 0.5, 
        -3.25, 4.32, 1.63, 5.18, -0.43, 
        7.11, 4.87, -3.10, -5.81, 3.76, 
        6.31, 2.58, 0.07, 5.76, 3.50)
)

kdensity_d1 <- tb %>%
  filter(d == 1) %>% 
  pull(y)
kdensity_d1 <- density(kdensity_d1)

kdensity_d0 <- tb %>%
  filter(d == 0) %>% 
  pull(y)
kdensity_d0 <- density(kdensity_d0)

kdensity_d0 <- tibble(x = kdensity_d0$x, y = kdensity_d0$y, d = 0)
kdensity_d1 <- tibble(x = kdensity_d1$x, y = kdensity_d1$y, d = 1)

kdensity <- full_join(kdensity_d1, kdensity_d0)
kdensity$d <- as_factor(kdensity$d)

ggplot(kdensity)+
  geom_point(size = 0.3, aes(x,y, color = d))+
  xlim(-7, 8)+
  labs(title = "Kolmogorov-Smirnov Test")+
  scale_color_discrete(labels = c("Control", "Treatment"))