#Remix - Properties of Regression
#October 11
#hsr

#--- Page 47 ...Let's consider an example in R
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
#- Plot
tb %>% 
  lm(y ~ x, .) %>% 
  ggplot(aes(x=x, y=y)) + 
    ggtitle("OLS Regression Line") +
    geom_point(size = 0.05, color = "black", alpha = 0.5) +
    geom_smooth(method = lm, color = "black") +
    annotate("text", x = -1.5, y = 30, color = "red", 
             label = paste("Intercept = ", 0.0732608)) +
    annotate("text", x = 1.5, y = -30, color = "blue", 
             label = paste("Slope =", 5.685033))

#--- Page 49 ...seeing is believing
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

#--- Page 55 ..when we use repeated sampling?
library(tidyverse)
library(magrittr)

lm <- lapply(
  1:1000,
  function(x) tibble(
    x = 9*rnorm(10000),
    u = 36*rnorm(10000),
    y = 3 + 2*x + u
  ) %>% 
  lm(y ~ x, .)
)
                                   
as_tibble(t(sapply(lm, coef))) %$%
  sd(x)

as_tibble(t(sapply(lm, coef))) %>% 
  ggplot()+
    geom_histogram(aes(x), binwidth = 0.01)
  
#--- Page 62 ...I find it helpful to visualize things. Let's look
library(tidyverse)
library(haven)

auto <- read_dta("http://www.stata-press.com/data/r9/auto.dta") %>% 
 mutate(length = length - mean(length))
  
lm1 <- lm(price ~ length, auto)
lm2 <- lm(price ~ length + weight + headroom + mpg, auto)

coef_lm1 <- lm1$coefficients
coef_lm2 <- lm2$coefficients
resid_lm2 <- lm2$residuals 
y_multi <- coef_lm1[1] + coef_lm2[2]*auto$length

ggplot(auto, aes(x=length, y=price)) + 
  ggtitle("Reganat") +
  geom_point(size = 1, color = "black") +
  geom_smooth(method = lm, color = "blue", se = FALSE) +
  geom_smooth(aes(y = y_multi, x = length), method = lm, color='red')


