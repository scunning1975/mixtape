library(tidyverse)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}


auto <- read_data("auto.dta") %>% 
  mutate(length = length - mean(length))

lm1 <- lm(price ~ length, auto)
lm2 <- lm(price ~ length + weight + headroom + mpg, auto)


coef_lm1 <- lm1$coefficients
coef_lm2 <- lm2$coefficients
resid_lm2 <- lm2$residuals 

y_single <- tibble(price = coef_lm1[1] + coef_lm1[2]*auto$length, 
                   length = auto$length)

y_multi <- tibble(price = coef_lm1[1] + coef_lm2[2]*auto$length, 
                  length = auto$length)


ggplot(auto) + 
  geom_point(aes(x = length, y = price)) +
  geom_smooth(aes(x = length, y = price), data = y_multi, color = "blue") +
  geom_smooth(aes(x = length, y = price), data = y_single, color="red")