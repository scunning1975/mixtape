library(tidyverse)
library(haven)
library(estimatr)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

abortion <- read_data("abortion.dta") %>% 
  mutate(
    repeal   = as_factor(repeal),
    year     = as_factor(year),
    fip      = as_factor(fip),
    fa       = as_factor(fa),
    younger2 = case_when(age == 20 ~ 1, TRUE ~ 0),
    yr2      = as_factor(case_when(repeal == 1 & younger2 == 1 ~ 1, TRUE ~ 0)),
    wm       = as_factor(case_when(wht == 1 & male == 1 ~ 1, TRUE ~ 0)),
    wf       = as_factor(case_when(wht == 1 & male == 0 ~ 1, TRUE ~ 0)),
    bm       = as_factor(case_when(wht == 0 & male == 1 ~ 1, TRUE ~ 0)),
    bf       = as_factor(case_when(wht == 0 & male == 0 ~ 1, TRUE ~ 0))
  )

regddd <- abortion %>% 
  filter(bf == 1 & (age == 20 | age ==25)) %>% 
  lm_robust(lnr ~ repeal*year + acc + ir + pi + alcohol + crack + poverty + income + ur,
            data = ., weights = totpop, clusters = fip)