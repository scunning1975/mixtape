
# This version includes
# an interval that traces the confidence intervals
# of your coefficients
leadslags_plot %>%
  ggplot(aes(x = label, y = mean,
             ymin = mean-1.96*sd, 
             ymax = mean+1.96*sd)) +
  # this creates a red horizontal line
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_line() + 
  geom_point() +
  geom_ribbon(alpha = 0.2) +
  theme_minimal() +
  # Important to have informative axes labels!
  xlab("Years before and after castle doctrine expansion") +
  ylab("log(Homicide Rate)") +
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = 0)
