# simultate nonlinearity
dat <- tibble(
    x = rnorm(1000, 100, 50)
  ) %>% 
  mutate(
    x = case_when(x < 0 ~ 0, TRUE ~ x),
    D = case_when(x > 140 ~ 1, TRUE ~ 0),
    x2 = x*x,
    x3 = x*x*x,
    y3 = 10000 + 0 * D - 100 * x + x2 + rnorm(1000, 0, 1000)
  ) %>% 
  filter(x < 280)


ggplot(aes(x, y3, colour = factor(D)), data = dat) +
  geom_point(alpha = 0.2) +
  geom_vline(xintercept = 140, colour = "grey", linetype = 2) +
  stat_smooth(method = "lm", se = F) +
  labs(x = "Test score (X)", y = "Potential Outcome (Y)")

ggplot(aes(x, y3, colour = factor(D)), data = dat) +
  geom_point(alpha = 0.2) +
  geom_vline(xintercept = 140, colour = "grey", linetype = 2) +
  stat_smooth(method = "loess", se = F) +
  labs(x = "Test score (X)", y = "Potential Outcome (Y)")

