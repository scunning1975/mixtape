sort beta_1
gen int sim_ID = _n
gen beta_1_True = 0

* Plot of the Confidence Interval
twoway rcap beta_1_l beta_1_u sim_ID if beta_1_l > 0 | beta_1_u < 0  , horizontal lcolor(pink) || || ///
rcap beta_1_l beta_1_u sim_ID if beta_1_l < 0 & beta_1_u > 0 , horizontal ysc(r(0)) || || ///
connected sim_ID beta_1 || || ///
line sim_ID beta_1_True, lpattern(dash) lcolor(black) lwidth(1) ///  
title("Least squares estimates of clustered data") subtitle(" 95% Confidence interval of the slope") ///
legend(label(1 "Missed") label(2 "Hit") label(3 "OLS estimates") label(4 "True population parameter")) xtitle("Parameter estimates") ///
ytitle("Simulation")

