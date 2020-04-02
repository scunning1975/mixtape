#Remix - Properties of Regression
#October 11
#Hugo Rodrigues


#--- Page 98 ...use scuse
#CODE 4.1
library(tidyverse)

yule <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/yule.dta") %>% 
  lm(paup ~ outrelief + old + pop, .)
  summary(yule)
  
  
#--- Page 110 ...Note the ATE
#CODE 4.2
library(tidyverse)
library(magrittr)
    
gap <- function() 
{
  sdo <-  tibble(
    y1 = c(7,5,5,7,4,10,1,5,3,9),
    y0 = c(1,6,1,8,2,1,10,6,7,8),
    random = rnorm(10)
    ) %>% 
      arrange(random) %>% 
      mutate(
        d = c(rep(1,5), rep(0,5)),
        y = d * y1 + (1 - d) * y0
        ) %$% 
    mean(y[1:5]-y[6:10])
  
  return(sdo)
}

sim <- replicate(10000, gap())
mean(sim)

# #--- Page 104 ...

# library(tidyverse)
# library(haven)
# 
# star_sw <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/star_sw.dta")
# 
# #--- Page 111
# library(tidyverse)
# 
# star_sw %>% 
#   lm(tscorek ~ sck + rak, .) %>% 
#   summary()

#--- Page 120 ...following code
#CODE 4.3
library(tidyverse)
library(utils)

correct <- tibble(
  cup   = c(1:8),
  guess = c(1:4,rep(0,4))
)

combo <- correct %$% as_tibble(t(combn(cup, 4))) %>%
  transmute(
    cup_1 = V1, cup_2 = V2,
    cup_3 = V3, cup_4 = V4) %>% 
  mutate(permutation = 1:70) %>%
  crossing(., correct) %>% 
  arrange(permutation, cup) %>% 
  mutate(correct = case_when(cup_1 == 1 & cup_2 == 2 &
                               cup_3 == 3 & cup_4 == 4 ~ 1,
                                                  TRUE ~ 0))
sum(combo$correct == 1)
p_value <- sum(combo$correct == 1)/nrow(combo)

#--- Page 127
#CODE 4.4
library(tidyverse)
library(magrittr)
library(haven)

ri <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/ri.dta") %>% 
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

#--- page 133
#CODE 4.5
library(tidyverse)
library(stats)

tb <- tibble(
  d = c(rep(0, 20), rep(1, 20)),
  y = c(0.22, -0.87, -2.39, -1.79, 0.37, -1.54, 1.28, -0.31, -0.74, 1.72, 
        0.38, -0.17, -0.62, -1.10, 0.30, 0.15, 2.30, 0.19, -0.50, -0.9,
        -5.13, -2.19, 2.43, -3.83, 0.5, -3.25, 4.32, 1.63, 5.18, -0.43, 
        7.11, 4.87, -3.10, -5.81, 3.76, 6.31, 2.58, 0.07, 5.76, 3.50)
)

kdensity_d1 <- tb %>%
  filter(d == 1) %>% 
  pull(y)
kdensity_d1 <- density(kdensity_d1)

kdensity_d0 <- tb %>%
  filter(d == 0) %>% 
  pull(y)
kdensity_d0 <- density(kdensity_d0)

kdensity_d0 <- tibble(x = kdensity_d0$x, y = kdensity_d0$y, d = 0)
kdensity_d1 <- tibble(x = kdensity_d1$x, y = kdensity_d1$y, d = 1)

kdensity <- full_join(kdensity_d1, kdensity_d0)
kdensity$d <- as_factor(kdensity$d)

ggplot(kdensity)+
  geom_point(size = 0.3, aes(x,y, color = d))+
  xlim(-7, 8)+
  labs(title = "Kolmogorov-Smirnov Test")+
  scale_color_discrete(labels = c("Control", "Treatment"))

#--- thronton_ri.do ---#
library(tidyverse)
library(haven)
 
hiv <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/thornton_hiv.dta")


# creating the permutations

tb <- NULL

permuteHIV <- function(df, random = TRUE){
  tb <- df
  first_half <- ceiling(nrow(tb)/2)
  second_half <- nrow(tb) - first_half
  
  if(random == TRUE){
    tb <- tb %>%
      sample_frac(1) %>%
      mutate(any = c(rep(1, first_half), rep(0, second_half)))
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

pvalue <- permutation %>% 
  filter(iteration == 1) %>% 
  pull(rank)/iterations



#--- Page 126 ...Star example OLD ONE ######## DO NOT USE
# library(tidyverse)
# library(haven)
# 
# hiv <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/thornton_hiv.dta")
# 
# #--- 126 ...idem
# #CODE 4.6
# 
# te1 <- hiv %>% 
#   filter(any == 1) %>% 
#   count(got) %>% 
#   na.omit()
# te1 <- te1$n[2]/(te1$n[1]+te1$n[2])
# 
# te0 <- hiv %>% 
#   filter(any == 0) %>% 
#   count(got) %>% 
#   na.omit()
# te0 <- te0$n[2]/(te0$n[1]+te0$n[2])
# 
# hiv <- hiv %>%
#   mutate(te1 = ifelse(any == 1 & got == 1, te1, 0),
#          te0 = ifelse(any == 0 & got == 1, te0, 0))
# 
# 
# 
# randomize <- function(tb, random = TRUE){
#   if(random == TRUE){
#     tb %<>% 
#       sample_frac(1) %>% 
#       mutate(sck = c(rep(1, 1290),rep(0, nrow(tb)-1290)))
#   }
#   
#   te1 <- tb %>% 
#     filter(sck == 1) %$% 
#     mean(tscorek, na.rm = TRUE)
#   
#   te0 <- tb %>% 
#     filter(sck == 0) %$%  
#     mean(tscorek, na.rm = TRUE)
#   
#   permute <- tibble(ate = te1 - te0,
#                      iteration = 1)
#   return(permute)
# }
# 
# permute1 <- randomize(star_sw, random = FALSE)
# 
# n = 1000
# permutations <- bind_rows(permute1, lapply(1:n, function(x) randomize(star_sw))) %>% 
#   mutate(iteration = c(1:(n+1))) %>% 
#   arrange(desc(ate)) %>% 
#   mutate(rank = c(1:(n+1)))
# 
# pvalue = permutations %>% 
#   filter(iteration == 1) %$%
#   rank/n


# te1 <- hiv %>% 
#   filter(any == 1) %>% 
#   count(got) %>% 
#   na.omit()
# te1 <- te1$n[2]/(te1$n[1]+te1$n[2])
# 
# te0 <- hiv %>% 
#   filter(any == 0) %>% 
#   count(got) %>% 
#   na.omit()
# te0 <- te0$n[2]/(te0$n[1]+te0$n[2])
# 
# hiv <- hiv %>%
#   mutate(te1 = ifelse(any == 1 & got == 1, te1, 0),
#          te0 = ifelse(any == 0 & got == 1, te0, 0))
# 
# ate <- te1 - te0
# iteration <- 1
####################################################



