use https://github.com/scunning1975/mixtape/raw/master/card.dta, clear
reg lwage  educ  exper black south married smsa
ivregress 2sls lwage (educ=nearc4) exper black south married smsa, first 
reg educ nearc4 exper black south married smsa
test nearc4
