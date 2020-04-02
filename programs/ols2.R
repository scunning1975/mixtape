library(tidyverse)

set.seed(1)

tb <- tibble(
  x = 9*rnorm(10),
  u = 36*rnorm(10),
  y = 3 + 2*x + u,
  yhat = predict(lm(y ~ x)),
  uhat = residuals(lm(y ~ x))
)

summary(tb)
colSums(tb)