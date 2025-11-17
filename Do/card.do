use https://github.com/scunning1975/mixtape/raw/master/card.dta, clear

* OLS estimate of schooling (educ) on log wages
reg lwage  educ  exper black south married smsa

* 2SLS estimate of schooling (educ) on log wages using "college in the county" as an instrument for schooling
ivregress 2sls lwage (educ=nearc4) exper black south married smsa, first 

* First stage regression of schooling (educ) on all covariates and the college and the county variable
reg educ nearc4 exper black south married smsa

* F test on the excludability of college in the county from the first stage regression.
test nearc4
