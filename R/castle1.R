library(bacondecomp)
library(tidyverse)
library(lfe)

castle <- read_dta("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/castle.dta")

#--- global variables
crime1 <- c("jhcitizen_c", "jhpolice_c", "murder", "homicide", "robbery", "assault", "burglary",
            "larceny", "motor", "robbery_gun_r")

demo <- c("emo", "blackm_15_24", "whitem_15_24", "blackm_25_44", "whitem_25_44")

lintrend <- colnames(
  castle %>%
    select(starts_with("trend"))
)

region <- colnames(
  castle %>%
    select(starts_with("r20"))
)

exocrime <- c("l_lacerny", "l_motor")
spending <- c("l_exp_subsidy", "l_exp_pubwelfare")


xvar <- c(
  "blackm_15_24", "whitem_15_24", "blackm_25_44", "whitem_25_44",
  "l_exp_subsidy", "l_exp_pubwelfare",
  "l_police", "unemployrt", "poverty", "l_income", "l_prisoner", "l_lagprisoner"
)

law <- c("cdl")

#--- Generating the formula
formula1 <- as.formula(
  paste("l_homicide ~ post + ",
        paste(
          paste(xvar, collapse = " + "),
          paste(region, collapse = " + "),
          paste(lintrend, collapse = " + "),
          paste(law, collapse = " + "), sep = " + "),
        "| year | 0 | sid"
  )
)

formula2 <- as.formula(
  paste("l_homicide ~ post + ",
        paste(
          paste(xvar, collapse = " + "),
          paste(region, collapse = " + "),
          paste(lintrend, collapse = " + "),
          paste("post", collapse = " + "), sep = " + "),
        "| year | 0 | sid"
  )
)

reg1 <- felm(formula1, weights = castle$popwt, data = castle)
reg2 <- felm(formula2, weights = castle$popwt, data = castle)