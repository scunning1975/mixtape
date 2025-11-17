* Plot the parameter estimate
hist beta_1, frequency addplot(pci 0 0 100 0) title("Least squares estimates of clustered Data") subtitle(" Monte Carlo simulation of the slope") legend(label(1 "Distribution of least squares estimates") label(2 "True population parameter")) xtitle("Parameter estimate")
