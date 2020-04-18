library(tidyverse)
library(haven)
library(estimatr)
library(plm)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

sasp <- read_data("sasp_panel.dta")

#-- Delete all NA
sasp <- na.omit(sasp)

#-- order by id and session 
sasp <- sasp %>% 
  arrange(id, session)

#Balance Data
balanced_sasp <- make.pbalanced(sasp, 
                                balance.type = "shared.individuals")

#Demean Data
balanced_sasp <- balanced_sasp %>% mutate( 
  demean_lnw = lnw - ave(lnw, id),
  demean_age = age - ave(age, id),
  demean_asq = asq - ave(asq, id),
  demean_bmi = bmi - ave(bmi, id),
  demean_hispanic = hispanic - ave(hispanic, id),
  demean_black = black - ave(black, id),
  demean_other = other - ave(other, id),
  demean_asian = asian - ave(asian, id),
  demean_schooling = schooling - ave(schooling, id),
  demean_cohab = cohab - ave(cohab, id),
  demean_married = married - ave(married, id),
  demean_divorced = divorced - ave(divorced, id),
  demean_separated = separated - ave(separated, id),
  demean_age_cl = age_cl - ave(age_cl, id),
  demean_unsafe = unsafe - ave(unsafe, id),
  demean_llength = llength - ave(llength, id),
  demean_reg = reg - ave(reg, id),
  demean_asq_cl = asq_cl - ave(asq_cl, id),
  demean_appearance_cl = appearance_cl - ave(appearance_cl, id),
  demean_provider_second = provider_second - ave(provider_second, id),
  demean_asian_cl = asian_cl - ave(asian_cl, id),
  demean_black_cl = black_cl - ave(black_cl, id),
  demean_hispanic_cl = hispanic_cl - ave(hispanic_cl, id),
  demean_othrace_cl = othrace_cl - ave(lnw, id),
  demean_hot = hot - ave(hot, id),
  demean_massage_cl = massage_cl - ave(massage_cl, id)
  )

#-- POLS
ols <- lm_robust(lnw ~ age + asq + bmi + hispanic + black + other + asian + schooling + cohab + married + divorced + separated + 
           age_cl + unsafe + llength + reg + asq_cl + appearance_cl + provider_second + asian_cl + black_cl + hispanic_cl + 
           othrace_cl + hot + massage_cl, data = balanced_sasp)
summary(ols)


#-- FE
formula <- as.formula("lnw ~ age + asq + bmi + hispanic + black + other + asian + schooling + 
                      cohab + married + divorced + separated + 
                      age_cl + unsafe + llength + reg + asq_cl + appearance_cl + 
                      provider_second + asian_cl + black_cl + hispanic_cl + 
                      othrace_cl + hot + massage_cl")

model_fe <- lm_robust(formula = formula,
                  data = balanced_sasp, 
                  fixed_effect = ~id, 
                  se_type = "stata")

summary(model_fe)

#-- Demean OLS
dm_formula <- as.formula("demean_lnw ~ demean_age + demean_asq + demean_bmi + 
                demean_hispanic + demean_black + demean_other +
                demean_asian + demean_schooling + demean_cohab + 
                demean_married + demean_divorced + demean_separated +
                demean_age_cl + demean_unsafe + demean_llength + demean_reg + 
                demean_asq_cl + demean_appearance_cl + 
                demean_provider_second + demean_asian_cl + demean_black_cl + 
                demean_hispanic_cl + demean_othrace_cl +
                demean_hot + demean_massage_cl")

ols_demean <- lm_robust(formula = dm_formula, 
                data = balanced_sasp, clusters = id,
                se_type = "stata")

summary(ols_demean)
