library(tidyverse)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

hiv <- read_data("thornton_hiv.dta")


# creating the permutations

tb <- NULL

permuteHIV <- function(df, random = TRUE){
  tb <- df
  # Number of treated in dataset
  n_treated <- 2222
  n_control <- nrow(tb) - n_treated
  
  if(random == TRUE){
    tb <- tb %>%
      sample_frac(1) %>%
      mutate(any = c(rep(1, n_treated), rep(0, n_control)))
  }
  
  te1 <- tb %>%
    filter(any == 1) %>%
    pull(got) %>%
    mean(na.rm = TRUE)
  
  te0 <- tb %>%
    filter(any == 0) %>%
    pull(got) %>% 
    mean(na.rm = TRUE)
  
  ate <-  te1 - te0
  
  return(ate)
}

permuteHIV(hiv, random = FALSE)

iterations <- 1000

permutation <- tibble(
  iteration = c(seq(iterations)), 
  ate = as.numeric(
    c(permuteHIV(hiv, random = FALSE), map(seq(iterations-1), ~permuteHIV(hiv, random = TRUE)))
  )
)

#calculating the p-value

permutation <- permutation %>% 
  arrange(-ate) %>% 
  mutate(rank = seq(iterations))

p_value <- permutation %>% 
  filter(iteration == 1) %>% 
  pull(rank)/iterations
