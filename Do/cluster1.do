clear all
set seed 20140
* Set the number of simulations
local n_sims  = 1000
set obs `n_sims'

* Create the variables that will contain the results of each simulation
generate beta_0 = .
generate beta_0_l = .
generate beta_0_u = .
generate beta_1 = .
generate beta_1_l = .
generate beta_1_u = .


* Provide the true population parameters
local beta_0_true = 0.4
local beta_1_true = 0
local rho = 0.5

* Run the linear regression 1000 times and save the parameters beta_0 and beta_1
quietly {
	forvalues i = 1(1) `n_sims' {
		preserve  
		clear
		set obs 100
		generate x = rnormal(0,1)
		generate e = rnormal(0, sqrt(1 - `rho'))
		generate y = `beta_0_true' + `beta_1_true'*x + e
		regress y x
		local b0 = _b[_cons]
		local b1 = _b[x]
		local df = e(df_r)
		local critical_value = invt(`df', 0.975)
		restore
		replace beta_0 = `b0' in `i'
		replace beta_0_l = beta_0 - `critical_value'*_se[_cons] 
		replace beta_0_u = beta_0 + `critical_value'*_se[_cons] 
		replace beta_1 = `b1' in `i'
		replace beta_1_l = beta_1 - `critical_value'*_se[x] 
		replace beta_1_u = beta_1 + `critical_value'*_se[x] 
		
	}
}
gen false = (beta_1_l > 0 )
replace false = 2 if beta_1_u < 0
replace false = 3 if false == 0
tab false

* Plot the parameter estimate
hist beta_1, frequency addplot(pci 0 0 100 0) title("Least squares estimates of non-clustered data") subtitle(" Monte Carlo simulation of the slope") legend(label(1 "Distribution of least squares estimates") label(2 "True population parameter")) xtitle("Parameter estimate") 

sort beta_1
gen int sim_ID = _n
gen beta_1_True = 0
* Plot of the Confidence Interval
twoway rcap beta_1_l beta_1_u sim_ID if beta_1_l > 0 | beta_1_u < 0  , horizontal lcolor(pink) || || ///
rcap beta_1_l beta_1_u sim_ID if beta_1_l < 0 & beta_1_u > 0 , horizontal ysc(r(0)) || || ///
connected sim_ID beta_1 || || ///
line sim_ID beta_1_True, lpattern(dash) lcolor(black) lwidth(1) ///  
title("Least squares estimates of non-clustered data") subtitle(" 95% Confidence interval of the slope") ///
legend(label(1 "Missed") label(2 "Hit") label(3 "OLS estimates") label(4 "True population parameter")) xtitle("Parameter estimates") ///
ytitle("Simulation")
