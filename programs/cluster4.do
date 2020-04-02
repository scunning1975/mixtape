* Robust Estimates
clear all
local n_sims = 1000
set obs `n_sims'

* Create the variables that will contain the results of each simulation
generate beta_0_robust = .
generate beta_0_l_robust = .
generate beta_0_u_robust = .
generate beta_1_robust = .
generate beta_1_l_robust = .
generate beta_1_u_robust = .

* Provide the true population parameters
local beta_0_true = 0.4
local beta_1_true = 0
local rho = 0.5

quietly {
forvalues i = 1(1) `n_sims' {
	preserve
	clear
	set obs 50
	
	* Generate cluster level data: clustered x and e
	generate int cluster_ID = _n
	generate x_cluster = rnormal(0,1)
	generate e_cluster = rnormal(0, sqrt(`rho'))
	expand 20
	bysort cluster_ID : gen int ind_in_clusterID = _n

	* Generate individual level data
	generate x_individual = rnormal(0,1)
	generate e_individual = rnormal(0,sqrt(1 - `rho'))

	* Generate x and e
	generate x = x_individual + x_cluster
	generate e = e_individual + e_cluster
	generate y = `beta_0_true' + `beta_1_true'*x + e
	regress y x, cl(cluster_ID)
	local b0_robust = _b[_cons]
	local b1_robust = _b[x]
	local df = e(df_r)
	local critical_value = invt(`df', 0.975)
	* Save the results
	restore
	replace beta_0_robust = `b0_robust' in `i'
	replace beta_0_l_robust = beta_0_robust - `critical_value'*_se[_cons]
	replace beta_0_u_robust = beta_0_robust + `critical_value'*_se[_cons]
	replace beta_1_robust = `b1_robust' in `i'
	replace beta_1_l_robust = beta_1_robust - `critical_value'*_se[x]
	replace beta_1_u_robust = beta_1_robust + `critical_value'*_se[x]

}
}

* Plot the histogram of the parameters estimates of the robust least squares
gen false = (beta_1_l_robust > 0 )
replace false = 2 if beta_1_u_robust < 0
replace false = 3 if false == 0
tab false

* Plot the parameter estimate
hist beta_1_robust, frequency addplot(pci 0 0 110 0) title("Robust least squares estimates of clustered data") subtitle(" Monte Carlo simulation of the slope") legend(label(1 "Distribution of robust least squares estimates") label(2 "True population parameter")) xtitle("Parameter estimate")

sort beta_1_robust
gen int sim_ID = _n
gen beta_1_True = 0

* Plot of the Confidence Interval
twoway rcap beta_1_l_robust beta_1_u_robust sim_ID if beta_1_l_robust > 0 | beta_1_u_robust < 0, horizontal lcolor(pink) || || rcap beta_1_l_robust beta_1_u_robust sim_ID if beta_1_l_robust < 0 & beta_1_u_robust > 0 , horizontal ysc(r(0)) || || connected sim_ID beta_1_robust || || line sim_ID beta_1_True, lpattern(dash) lcolor(black) lwidth(1) title("Robust least squares estimates of clustered data") subtitle(" 95% Confidence interval of the slope") legend(label(1 "Missed") label(2 "Hit") label(3 "Robust estimates") label(4 "True population parameter")) xtitle("Parameter estimates") ytitle("Simulation")
