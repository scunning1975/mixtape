
# order of the coefficients for the plot
plot_order <- c("lead9", "lead8", "lead7", 
                "lead6", "lead5", "lead4", "lead3", 
                "lead2", "lead1", "lag1", 
                "lag2", "lag3", "lag4", "lag5")

# grab the clustered standard errors
# and average coefficient estimates
# from the regression, label them accordingly
# add a zero'th lag for plotting purposes
leadslags_plot <- tibble(
  sd = c(event_study_reg$cse[plot_order], 0),
  mean = c(coef(event_study_reg)[plot_order], 0),
  label = c(-9,-8,-7,-6, -5, -4, -3, -2, -1, 1,2,3,4,5, 0)
)

# This version has a point-range at each
# estimated lead or lag
# comes down to stylistic preference at the
# end of the day!
leadslags_plot %>%
  ggplot(aes(x = label, y = mean,
             ymin = mean-1.96*sd, 
             ymax = mean+1.96*sd)) +
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_pointrange() +
  theme_minimal() +
  xlab("Years before and after castle doctrine expansion") +
  ylab("log(Homicide Rate)") +
  geom_hline(yintercept = 0,
             linetype = "dashed") +
  geom_vline(xintercept = 0,
             linetype = "dashed")
  


