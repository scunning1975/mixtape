clear all
set seed 20140
local n_sims = 1000
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

* Simulate a linear regression. Clustered data (x and e are clustered)


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
	
* Least Squares Estimates
	regress y x
	local b0 = _b[_cons]
	local b1 = _b[x]
	local df = e(df_r)
	local critical_value = invt(`df', 0.975)
	* Save the results
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
hist beta_1, frequency addplot(pci 0 0 100 0) title("Least squares estimates of clustered Data") subtitle(" Monte Carlo simulation of the slope") legend(label(1 "Distribution of least squares estimates") label(2 "True population parameter")) xtitle("Parameter estimate")

