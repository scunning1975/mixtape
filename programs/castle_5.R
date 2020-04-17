library(bacondecomp)
library(lfe)

df_bacon <- bacon(l_homicide ~ post,
                  data = castle, id_var = "state",
                  time_var = "year")

# Diff-in-diff estimate is the weighted average of 
# individual 2x2 estimates
dd_estimate <- sum(df_bacon$estimate*df_bacon$weight)

# 2x2 Decomposition Plot
bacon_plot <- ggplot(data = df_bacon) +
  geom_point(aes(x = weight, y = estimate, 
                 color = type, shape = type), size = 2) +
  xlab("Weight") +
  ylab("2x2 DD Estimate") +
  geom_hline(yintercept = dd_estimate, color = "red") +
  theme_minimal() + 
  theme(
    legend.title = element_blank(),
    legend.background = element_rect(
      fill="white", linetype="solid"),
    legend.justification=c(1,1), 
    legend.position=c(1,1)
  )

bacon_plot

# create formula
formula4 <- as.formula(
  'l_homicide ~ post | year + sid | 0 | sid')

# Simple diff-in-diff regression
reg4 <- felm(formula = formula4, data = castle)
summary(reg4)

# Note that the estimate from earlier equals the 
# coefficient on post
dd_estimate

