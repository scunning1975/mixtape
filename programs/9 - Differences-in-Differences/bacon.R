# Bacondecomp
# 01-26-2016
# Mixtape Project

library(bacondecomp)
library(tidyverse)
library(lfe)

castle <- castle



#----- formula vanilla from the package example ----#
df_bacon <- bacon(l_homicide ~ post,
                  data = bacondecomp::castle, id_var = "state",
                  time_var = "year")

#--- template for creating a formula ---#
xnam <- paste("x", 1:25, sep="")
fmla <- as.formula(paste("y ~ ", paste(xnam, collapse= "+")))

#--- getting var names
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


castle <- castle %>%
  mutate(
    time_til = year - treatment_date,
    lead1 = case_when(time_til == -1 ~ 1, TRUE ~ 0),
    lead2 = case_when(time_til == -2 ~ 1, TRUE ~ 0),
    lead3 = case_when(time_til == -3 ~ 1, TRUE ~ 0),
    lead4 = case_when(time_til == -4 ~ 1, TRUE ~ 0),
    lead5 = case_when(time_til == -5 ~ 1, TRUE ~ 0),
    lead6 = case_when(time_til == -6 ~ 1, TRUE ~ 0),
    lead7 = case_when(time_til == -7 ~ 1, TRUE ~ 0),
    lead8 = case_when(time_til == -8 ~ 1, TRUE ~ 0),
    lead9 = case_when(time_til == -9 ~ 1, TRUE ~ 0),

    lag0 = case_when(time_til == 0 ~ 1, TRUE ~ 0),
    lag1 = case_when(time_til == 1 ~ 1, TRUE ~ 0),
    lag2 = case_when(time_til == 2 ~ 1, TRUE ~ 0),
    lag3 = case_when(time_til == 3 ~ 1, TRUE ~ 0),
    lag4 = case_when(time_til == 4 ~ 1, TRUE ~ 0),
    lag5 = case_when(time_til == 5 ~ 1, TRUE ~ 0)
  )

paste(paste("lead", 1:9, sep = ""), collapse = " + ")
paste(paste("lag", 1:5, sep = ""), collapse = " + ")

formula3 <- as.formula(
  paste("l_homicide ~ + ",
        paste(
          paste(region, collapse = " + "),
          paste(paste("lead", 1:9, sep = ""), collapse = " + "),
          paste(paste("lag", 1:5, sep = ""), collapse = " + "), sep = " + "),
        "| year + state | 0 | sid"
        ),
)

reg3 <- felm(formula3, weights = castle$popwt, data = castle)

leadslags_plot <- tibble(
  sd = c(reg3$cse[53:45], reg3$se[54:58]),
  mean = c(reg3$coefficients[53:45], reg3$se[54:58]),
  label = c(-9,-8,-7,-6, -5, -4, -3, -2, -1, 1,2,3,4,5)
)

leadslags_plot %>%
  ggplot(aes(x = label, y = mean)) +
  geom_point()+
  geom_text(aes(label = label), hjust=-0.002, vjust = -0.03)+
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd), width = 0.2,
                position = position_dodge(0.05))

leadslags_plot <- rbind(leadslags_plot, c(0,0,0))

leadslags_plot %>%
  ggplot(aes(x = label, y = mean)) +
  geom_point()+
  #geom_text(aes(label = round(mean,3), color = "red"), hjust=-0.002, vjust = -0.03)+
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_line() +
  geom_ribbon(aes(ymin = mean-sd, ymax = mean+sd), alpha = 0.2,
                position = position_dodge(0.05))





