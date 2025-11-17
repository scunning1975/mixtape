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
