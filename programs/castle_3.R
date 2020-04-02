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

leadslags_plot <- tibble(
  sd = c(reg3$cse[53:45], reg3$se[54:58]),
  mean = c(reg3$coefficients[53:45], reg3$se[54:58]),
  label = c(-9,-8,-7,-6, -5, -4, -3, -2, -1, 1,2,3,4,5)
)

leadslags_plot %>%
  ggplot(aes(x = label, y = mean)) +
  geom_point()+
  geom_text(aes(label = round(mean, 3), color = "red"), hjust = -0.002, vjust = -0.03)+
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_errorbar(aes(ymin = mean-1.96*sd, ymax = mean+1.96*sd), width = 0.2,
                position = position_dodge(0.05))



