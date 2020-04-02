leadslags_plot <- rbind(leadslags_plot, c(0,0,0))

leadslags_plot %>%
  ggplot(aes(x = label, y = mean)) +
  geom_point()+
  geom_hline(yintercept = 0, color = "black") +
  geom_vline(xintercept = 0, color = "black") +
  geom_hline(yintercept = 0.035169444, color = "red") +
  geom_line() +
  geom_ribbon(aes(ymin = mean-sd, ymax = mean+sd), alpha = 0.2,
              position = position_dodge(0.05))
