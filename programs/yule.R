library(tidyverse)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

yule <- read_data("yule.dta") %>% 
  lm(paup ~ outrelief + old + pop, .)
summary(yule)
