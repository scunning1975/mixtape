library(tidyverse)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

titanic <- read_data("titanic.dta") %>% 
  mutate(d = case_when(class == 1 ~ 1, TRUE ~ 0))

ey1 <- titanic %>% 
  filter(d == 1) %>%
  pull(survived) %>% 
  mean()

ey0 <- titanic %>% 
  filter(d == 0) %>%
  pull(survived) %>% 
  mean()

sdo <- ey1 - ey0