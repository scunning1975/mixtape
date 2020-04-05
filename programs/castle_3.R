
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



