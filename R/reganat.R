library(tidyverse)
library(haven)

read_data <- function(df) {
  full_path <- paste0("https://raw.github.com/scunning1975/mixtape/master/",
                      df)
  haven::read_dta(full_path)
}

auto <-
  read_data("auto.dta") %>%
  mutate(length = length - mean(length))

lm1 <- lm(price ~ length, auto)
lm2 <- lm(price ~ length + weight + headroom + mpg, auto)
lm_aux <- lm(length ~ weight + headroom + mpg, auto)
auto <-
  auto %>%
  mutate(length_resid = residuals(lm_aux))

lm2_alt <- lm(price ~ length_resid, auto)

coef_lm1 <- lm1$coefficients
coef_lm2_alt <- lm2_alt$coefficients
resid_lm2 <- lm2$residuals

y_single <- tibble(price = coef_lm2_alt[1] + coef_lm1[2]*auto$length_resid,
                   length_resid = auto$length_resid)

y_multi <- tibble(price = coef_lm2_alt[1] + coef_lm2_alt[2]*auto$length_resid,
                  length_resid = auto$length_resid)

auto %>%
  ggplot(aes(x=length_resid, y = price)) +
  geom_point() +
  geom_smooth(data = y_multi, color = "blue") +
  geom_smooth(data = y_single, color = "red")
