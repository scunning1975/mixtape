#Remix - DAGs
#October 11
#hsr

#--- Page 85
library(tidyverse)
library(stargazer)

tb <- tibble(
  female = ifelse(runif(10000)>=0.5,1,0),
  ability = rnorm(10000),
  discrimination = female,
  occupation = 1 + 2*ability + 0*female - 2*discrimination + rnorm(10000),
  wage = 1 - 1*discrimination + 1*occupation + 2*ability + rnorm(10000) 
)

lm_1 <- lm(wage ~ female, tb)
lm_2 <- lm(wage ~ female + occupation, tb)
lm_3 <- lm(wage ~ female + occupation + ability, tb)

stargazer(lm_1,lm_2,lm_3, type = "text", 
          column.labels = c("Biased Unconditional", 
                            "Biased",
                            "Unbiased Unconditional"))

#--- Page 87 ...or worse, even switches sign
library(tidyverse)
library(MASS) #for robust regression

set.seed(541)

collider <- tibble(
  z = rnorm(2500),
  k = rnorm(2500, 10,4),
  d = ifelse(k>=12,1,0),
  
  y = d*50 + 100 + rnorm(2500),
  x = d*50 + y + rnorm(2500,50,1)
)

rlm_1 = rlm(y ~ d, collider)
rlm_2 = rlm(y ~ x, collider)
rlm_3 = rlm(y ~ x + d, collider)

stargazer(rlm_1,rlm_2,rlm_3, type = "text")


#--- Page 88  ...To illustrate
library(tidyverse)

set.seed(3444)

star_is_born <- tibble(
  beauty = rnorm(2500),
  talent = rnorm(2500),
  score = beauty + talent,
  c85 = quantile(score, .85),
  star = ifelse(score>=c85,1,0)
)

star_is_born %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

star_is_born %>% 
  filter(star == 1) %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

star_is_born %>% 
  filter(star == 0) %>% 
  lm(beauty ~ talent, .) %>% 
  ggplot(aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)



library(haven)

setwd("~/Desktop")

abortion <- haven::read_dta("txdd.dta")

save(abortion, file = "txdd.rda")

