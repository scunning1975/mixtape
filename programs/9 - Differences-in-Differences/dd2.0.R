#--- 
# hsr
# Difference in Difference 2.0
#--- 

#--- Page 350

#- Code 9.1

library(tidyverse)
library(haven)
library(estimatr)

abortion <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/abortion.dta") %>% 
  mutate(
    repeal = as_factor(repeal),
    year   = as_factor(year),
    fip    = as_factor(fip),
    fa     = as_factor(fa),
  )

reg <- abortion %>% 
    filter(bf15 == 1) %>% 
    lm_robust(lnr ~ repeal*year + fip + acc + ir + pi + alcohol+ crack + poverty+ income+ ur,
               data = ., weights = totpop, clusters = fip)

abortion_plot <- tibble(
  sd = reg$std.error[-1:-75],
  mean = reg$coefficients[-1:-75],
  year = c(1986:2000))

abortion_plot %>% 
  ggplot(aes(x = year, y = mean)) + 
  geom_rect(aes(xmin=1986, xmax=1992, ymin=-Inf, ymax=Inf), fill = "cyan", alpha = 0.01)+
  geom_point()+
  geom_text(aes(label = year), hjust=-0.002, vjust = -0.03)+
  geom_hline(yintercept = 0) +
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = 0.2,
                position = position_dodge(0.05))

#DDD --- Page 311
library(tidyverse)
library(haven)
library(estimatr)

abortion <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/abortion.dta") %>% 
  mutate(
    repeal  = as_factor(repeal),
    year    = as_factor(year),
    fip     = as_factor(fip),
    fa      = as_factor(fa),
    younger = as_factor(younger),
    yr      = as_factor(case_when(repeal == 1 & younger == 1 ~ 1, TRUE ~ 0)),
    wm      = as_factor(case_when(wht == 1 & male == 1 ~ 1, TRUE ~ 0)),
    wf      = as_factor(case_when(wht == 1 & male == 0 ~ 1, TRUE ~ 0)),
    bm      = as_factor(case_when(wht == 0 & male == 1 ~ 1, TRUE ~ 0)),
    bf      = as_factor(case_when(wht == 0 & male == 0 ~ 1, TRUE ~ 0))
  ) %>% 
  filter(bf == 1 & (age == 15 | age == 25))

regddd <- lm_robust(lnr ~ repeal*year + younger*repeal + younger*year + yr*year + fip*t + acc + ir + pi + alcohol + crack + poverty + income + ur,
                    data = abortion, weights = totpop, clusters = fip)

abortion_plot <- tibble(
  sd = regddd$std.error[110:124],
  mean = regddd$coefficients[110:124],
  year = c(1986:2000))

abortion_plot %>% 
  ggplot(aes(x = year, y = mean)) + 
  geom_rect(aes(xmin=1986, xmax=1992, ymin=-Inf, ymax=Inf), fill = "cyan", alpha = 0.01)+
  geom_point()+
  geom_text(aes(label = year), hjust=-0.002, vjust = -0.03)+
  geom_hline(yintercept = 0) +
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = 0.2,
                position = position_dodge(0.05))

#black females aged 20-24 --- Page 314
#Code 9.2
library(tidyverse)
library(haven)
library(estimatr)

abortion <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/abortion.dta") %>% 
  mutate(
    repeal = as_factor(repeal),
    year   = as_factor(year),
    fip    = as_factor(fip),
    fa     = as_factor(fa),
  )

reg <- abortion %>% 
  filter(race == 2 & sex == 2 & age == 20) %>% 
  lm_robust(lnr ~ repeal*year + fip + acc + ir + pi + alcohol+ crack + poverty+ income+ ur,
            data = ., weights = totpop, clusters = fip)


#DDD aged 20-24 --- Page 314
#Code 9.3
library(tidyverse)
library(haven)
library(estimatr)

abortion <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/abortion.dta") %>% 
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


#Bacon Stuff --- 341

library(bacondecomp)

castle <- bacondecomp::castle


# devtools::install_github("evanjflack/bacon", force = T)
# library(bacon)
# 
# math_reform <- bacon::math_reform
# math_reform[is.na(math_reform$reformyr_math), "reformyr_math"] <- 99999
# 
# two_by_twos <- bacon(math_reform, id_var = "state", time_var = "class", 
#                      treat_time_var = "reformyr_math",  treated_var = "reform_math", 
#                      outcome_var = "incearn_ln")
# 
# weighted.mean(two_by_twos$estimate, two_by_twos$weight)


