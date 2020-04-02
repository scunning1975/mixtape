use https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta, clear
su re78 if treat
gen y1 = r(mean)
su re78 if treat==0
gen y0 = r(mean)
gen ate = y1-y0
su ate
di 6349.144 - 4554.801
* ATE is 1794.34 
drop if treat==0
drop y1 y0 ate
compress

* Now merge in the CPS controls from footnote 2 of Table 2 (Dehejia and Wahba 2002)
append using https://storage.googleapis.com/causal-inference-mixtape.appspot.com/cps_mixtape.dta
gen agesq=age*age
gen agecube=age*age*age
gen edusq=educ*edu
gen u74 = 0 if re74!=.
replace u74 = 1 if re74==0
gen u75 = 0 if re75!=.
replace u75 = 1 if re75==0
gen interaction1 = educ*re74
gen re74sq=re74^2
gen re75sq=re75^2
gen interaction2 = u74*hisp

* Now estimate the propensity score
logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore

* Checking mean propensity scores for treatment and control groups
su pscore if treat==1, detail
su pscore if treat==0, detail

* Now look at the propensity score distribution for treatment and control groups
histogram pscore, by(treat) binrescale

tempfile main
save "`main'", replace


* Manual calculation of non-normalized weights based on HT method
gen weight = (treat - pscore)/(pscore * (1-pscore)) if treat==1
gen te = re78*weight if treat==1
su te if treat==1


* Dan Millimet's HT weighting w/ slightly different notation.
gen y1=(treat*re78)/pscore
gen y0=((1-treat)*re78)/(1-pscore)
gen att_ht1 = y1-y0 if treat==1
su te att_ht1 if treat==1
drop y1 y0


* Normalized weighting (Hirano and Imbens 2001)
gen d1=treat/pscore 
gen d0 = (1-treat)/(1-pscore)
egen s1=sum(d1)
egen s0=sum(d0)


gen y1=((treat*re78)/pscore)/(s1/_N) if treat==1
gen y0=(((1-treat)*re78)/(1-pscore))/(s0/_N) if treat==1
gen norm=y1-y0 if treat==1
su te att_ht1 norm if treat==1


* Bootstrap the standard errors with the non-normalized weights
collapse att
label variable att "Propensity score weighted ATT"
gen 	iteration = 1
tempfile hajek_bs1
save "`hajek_bs1'", replace

* Create a thousand datasets
forvalues i = 2/1000 {
use "`main'", replace

* 50% sample
set seed `i'
gen random_`i' = runiform()
keep if random_`i'>=0.25
drop random*

* Calculate the propensity score
cap n drop pscore
quietly logit treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1 
predict pscore

* Calculate the ATT on the bootstrapped sample
egen at = sum(re78 * (treat - pscore)/ (1-pscore))
count if treat==1
gen att = at/`r(N)'
su att
collapse att
label variable att "Propensity score weighted ATT"

tempfile hajek_bs`i'
save "`hajek_bs`i''", replace

}

use "`hajek_bs1'", replace
forvalues i = 2/1000 {
    append using "`hajek_bs`i''"
}

tempfile final
save "`final'", replace

* Calculate bootstrapped standard error
gsort -att
su att
su att if iteration==1
cap n local beta = `r(mean)'
gen beta = `r(mean)'
su att if iteration!=1
cap n local sd = `r(sd)'
gen sd = `r(sd)'

di `beta'
* 1357.436
di `sd'
* 490.80697

gen test = beta/(2*sd)

use `main', replace


* Use teffects to calculate inverse probability weighted regression
gen re78_scaled = re78/10000
cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap)
keep if overlap==0
drop overlap
cap n teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap)
cap drop overlap

* Trimming the propensity score
drop if pscore <= 0.1 
drop if pscore >= 0.9
teffects ipw (re78_scaled) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), osample(overlap) atet
 

* Nearest neighbor matching
teffects psmatch (re78) (treat age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, logit), atet gen(pstub_cps) nn(3)

* Coarsened exact matching
ssc install cem, replace
cem age (10 20 30 40 60) age agesq agecube educ edusq marr nodegree black hisp re74 re75 u74 u75 interaction1, treatment(treat)
reg re78 treat [iweight=cem_weights], robust
