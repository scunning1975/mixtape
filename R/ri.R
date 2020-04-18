library(tidyverse)
library(magrittr)
library(haven)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

ri <- read_data("ri.dta") %>% 
  mutate(id = c(1:8))

treated <- c(1:4)

combo <- ri %$% as_tibble(t(combn(id, 4))) %>%
  transmute(
    treated1 = V1, treated2 = V2,
    treated3 = V3, treated4 = V4) %>%
  mutate(permutation = 1:70) %>%
  crossing(., ri) %>%
  arrange(permutation, name) %>% 
  mutate(d = case_when(id == treated1 | id == treated2 |
                         id == treated3 | id == treated4 ~ 1,
                       TRUE ~ 0))

te1 <- combo %>%
  group_by(permutation) %>%
  filter(d == 1) %>% 
  summarize(te1 = mean(y, na.rm = TRUE))

te0 <- combo %>%
  group_by(permutation) %>%
  filter(d == 0) %>% 
  summarize(te0 = mean(y, na.rm = TRUE))

n <- nrow(inner_join(te1, te0, by = "permutation"))

p_value <- inner_join(te1, te0, by = "permutation") %>%
  mutate(ate = te1 - te0) %>% 
  select(permutation, ate) %>% 
  arrange(ate) %>% 
  mutate(rank = 1:nrow(.)) %>% 
  filter(permutation == 1) %>%
  pull(rank)/n