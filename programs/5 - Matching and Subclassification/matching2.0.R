#Remix - Properties of Regression
#October 12
#hsr

#--- Page 151  ...before we use subclassification
#CODE 5.1
library(tidyverse)
library(haven)

titanic <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/titanic.dta") %>% 
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

#--- Next Example
#CODE 5.2
library(stargazer)
library(magrittr) # for %$% pipes
library(tidyverse)
library(haven)

titanic <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/titanic.dta") %>% 
  mutate(d = case_when(class == 1 ~ 1, TRUE ~ 0))


titanic %<>%
  mutate(s = case_when(sex == 0 & age == 1 ~ 1,
                       sex == 0 & age == 0 ~ 2,
                       sex == 1 & age == 1 ~ 3,
                       sex == 1 & age == 0 ~ 4,
                       TRUE ~ 0))

ey11 <- titanic %>% 
  filter(s == 1 & d == 1) %$%
  mean(survived)

ey10 <- titanic %>% 
  filter(s == 1 & d == 0) %$%
  mean(survived)

ey21 <- titanic %>% 
  filter(s == 2 & d == 1) %$%
  mean(survived)

ey20 <- titanic %>% 
  filter(s == 2 & d == 0) %$%
  mean(survived)

ey31 <- titanic %>% 
  filter(s == 3 & d == 1) %$%
  mean(survived)

ey30 <- titanic %>% 
  filter(s == 3 & d == 0) %$%
  mean(survived)

ey41 <- titanic %>% 
  filter(s == 4 & d == 1) %$%
  mean(survived)

ey40 <- titanic %>% 
  filter(s == 4 & d == 0) %$%
  mean(survived)

diff1 = ey11 - ey10
diff2 = ey21 - ey20
diff3 = ey31 - ey30
diff4 = ey41 - ey40

obs = nrow(titanic)

wt1 <- titanic %>% 
  filter(s == 1 & d == 0) %$%
  nrow(.)/obs

wt2 <- titanic %>% 
  filter(s == 2 & d == 0) %$%
  nrow(.)/obs

wt3 <- titanic %>% 
  filter(s == 3 & d == 0) %$%
  nrow(.)/obs

wt4 <- titanic %>% 
  filter(s == 4 & d == 0) %$%
  nrow(.)/obs

wate = diff1*wt1 + diff2*wt2 + diff3*wt3 + diff4*wt4

stargazer(wate, sdo, type = "text")


#--- Page 157####
#Code 5.3
library(tidyverse)
library(haven)

training_example <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/training_example.dta") %>% 
  slice(1:20)

ggplot(training_example, aes(x=age_treat)) +
  stat_bin(bins = 10, na.rm = TRUE)
  
ggplot(training_example, aes(x=age_control)) +
  geom_histogram(bins = 10, na.rm = TRUE)

# ggplot(training_example, aes(x=age_matched)) +
#   geom_histogram(bins = 5, na.rm = TRUE) +
#   geom_vline(aes(xintercept = mean(na.omit(age_matched))),
#              color = "blue", linetype = "dashed", size = 1)

library(stargazer)
stargazer(training_example, type = "text")


#--- Page 160####
#Code 5.4
library(tidyverse)
library(haven)

training_example <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/training_example.dta") %>% 
  slice(1:20)

ggplot(training_example, aes(x=age_treat)) +
  stat_bin(bins = 10, na.rm = TRUE)

ggplot(training_example, aes(x=age_matched)) +
  geom_histogram(bins = 5, na.rm = TRUE) +
  geom_vline(aes(xintercept = mean(na.omit(age_matched))),
             color = "blue", linetype = "dashed", size = 1)

library(stargazer)
stargazer(training_example, type = "text")


#----- ---  Page 166
#CODE 5.5

library(haven)
library(tidyverse)

training_bias_reduction = read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/training_bias_reduction.dta")

train.reg = lm(Y ~ X, training_bias_reduction)
predict(train.reg)

#-- 175
#CODE 5.6

library(haven)
nsw_dw <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/nsw_dw.dta")

summary(nsw_dw$re78[nsw_dw$treat == 1])
nsw_dw$y1 <- mean(nsw_dw$re78[nsw_dw$treat == 1])

summary(nsw_dw$re78[nsw_dw$treat == 0])
nsw_dw$y0 <- mean(nsw_dw$re78[nsw_dw$treat == 0])

nsw_dw$ate = nsw_dw$y1 - nsw_dw$y0

unique(nsw_dw$ate)
6349.144 - 4554.801

#Append part
nsw_dw_cpscontrol <- read_dta("http://scunning.com/teaching/cps_controls.dta")
nsw_dw <- merge(nsw_dw, nsw_dw_cpscontrol, all = TRUE)

nsw_dw$agesq <- nsw_dw$age*nsw_dw$age
nsw_dw$agecube <- nsw_dw$age^3

nsw_dw$school <- nsw_dw$education
nsw_dw$education <- NULL

nsw_dw$schoolsq <- nsw_dw$school^2 

nsw_dw$u74 <- ifelse(nsw_dw$re74==0, 1, 0)
nsw_dw$u75 <- ifelse(nsw_dw$re75==0, 1, 0)

nsw_dw$interaction1 <- nsw_dw$school*nsw_dw$re74

nsw_dw$re74sq <- nsw_dw$re74^2
nsw_dw$re75sq <- nsw_dw$re75^2

nsw_dw$interaction1 <- nsw_dw$u74*nsw_dw$hispanic

logit_nsw <- glm(treat ~ age + agesq + agecube + school + schoolsq +
                 married + nodegree + black + hispanic + re74 + re75 + u74 +
                   u75 + interaction1, family = binomial(link = "logit"), data = nsw_dw)

summary(logit_nsw)

pscore <- predict(logit_nsw)











