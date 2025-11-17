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

event_study_formula <- as.formula(
  paste("l_homicide ~ + ",
        paste(
          paste(region, collapse = " + "),
          paste(paste("lead", 1:9, sep = ""), collapse = " + "),
          paste(paste("lag", 1:5, sep = ""), collapse = " + "), sep = " + "),
        "| year + state | 0 | sid"
  ),
)

event_study_reg <- felm(event_study_formula, weights = castle$popwt, data = castle)
summary(event_study_reg)
