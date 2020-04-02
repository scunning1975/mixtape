library(tidyverse)

set.seed(1)
tb <- tibble(
  x = rnorm(10000),
  u = rnorm(10000),
  y = 5.5*x + 12*u
) 

reg_tb <- tb %>% 
  lm(y ~ x, .) %>%
  print()

reg_tb$coefficients

tb <- tb %>% 
  mutate(
    yhat1 = predict(lm(y ~ x, .)),
    yhat2 = 0.0732608 + 5.685033*x, 
    uhat1 = residuals(lm(y ~ x, .)),
    uhat2 = y - yhat2
  )

summary(tb[-1:-3])

tb %>% 
  lm(y ~ x, .) %>% 
  ggplot(aes(x=x, y=y)) + 
  ggtitle("OLS Regression Line") +
  geom_point(size = 0.05, color = "black", alpha = 0.5) +
  geom_smooth(method = lm, color = "black") +
  annotate("text", x = -1.5, y = 30, color = "red", 
           label = paste("Intercept = ", -0.0732608)) +
  annotate("text", x = 1.5, y = -30, color = "blue", 
           label = paste("Slope =", 5.685033))