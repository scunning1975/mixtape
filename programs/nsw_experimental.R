library(tidyverse)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

nsw_dw <- read_data("nsw_mixtape.dta")

nsw_dw %>% 
  filter(treat == 1) %>% 
  summary(re78)

mean1 <- nsw_dw %>% 
  filter(treat == 1) %>% 
  pull(re78) %>% 
  mean()

nsw_dw$y1 <- mean1

nsw_dw %>% 
  filter(treat == 0) %>% 
  summary(re78)

mean0 <- nsw_dw %>% 
  filter(treat == 0) %>% 
  pull(re78) %>% 
  mean()

nsw_dw$y0 <- mean0

ate <- unique(nsw_dw$y1 - nsw_dw$y0)

nsw_dw <- nsw_dw %>% 
  filter(treat == 1) %>% 
  select(-y1, -y0)