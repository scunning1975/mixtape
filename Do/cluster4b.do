* Plot the parameter estimate
hist beta_1_robust, frequency addplot(pci 0 0 110 0) title("Robust least squares estimates ///
of clustered data") subtitle(" Monte Carlo simulation of the slope") ///
legend(label(1 "Distribution of robust least squares estimates") ///
label(2 "True population parameter")) xtitle("Parameter estimate")


sort beta_1_robust
gen int sim_ID = _n
gen beta_1_True = 0
* Plot of the Confidence Interval
twoway rcap beta_1_l_robust beta_1_u_robust sim_ID if beta_1_l_robust > 0 | beta_1_u_robust < 0, ///
horizontal lcolor(pink) || || rcap beta_1_l_robust beta_1_u_robust sim_ID if beta_1_l_robust < 0 & ///
beta_1_u_robust > 0 , horizontal ysc(r(0)) || || connected sim_ID beta_1_robust || || ///
line sim_ID beta_1_True, lpattern(dash) lcolor(black) lwidth(1) ///  
title("Robust least squares estimates of clustered data") ///
subtitle(" 95% Confidence interval of the slope") legend(label(1 "Missed") label(2 "Hit") ///
label(3 "Robust estimates") label(4 "True population parameter")) xtitle("Parameter estimates") ///
ytitle("Simulation")
