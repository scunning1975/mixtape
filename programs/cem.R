library(cem)
library(MatchIt)
library(Zelig)
library(tidyverse)
library(estimatr)


m_out <- matchit(treat ~ age + agesq + agecube + educ +
                   educsq + marr + nodegree +
                   black + hisp + re74 + re75 + 
                   u74 + u75 + interaction1,
                 data = nsw_dw_cpscontrol, 
                 method = "cem", 
                 distance = "logit")

m_data <- match.data(m_out)

m_ate <- lm_robust(re78 ~ treat, 
               data = m_data,
               weights = m_data$weights)
