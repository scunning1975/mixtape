library(tidyverse)

lm <- lapply(
  1:1000,
  function(x) tibble(
    x = 9*rnorm(10000),
    u = 36*rnorm(10000),
    y = 3 + 2*x + u
  ) %>% 
    lm(y ~ x, .)
)

as_tibble(t(sapply(lm, coef))) %>%
  summary(x)

as_tibble(t(sapply(lm, coef))) %>% 
  ggplot()+
  geom_histogram(aes(x), binwidth = 0.01)