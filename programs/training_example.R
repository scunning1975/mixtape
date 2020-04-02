library(tidyverse)
library(haven)

training_example <- read_data("training_example.dta") %>% 
  slice(1:20)

ggplot(training_example, aes(x=age_treat)) +
  stat_bin(bins = 10, na.rm = TRUE)

ggplot(training_example, aes(x=age_control)) +
  geom_histogram(bins = 10, na.rm = TRUE)