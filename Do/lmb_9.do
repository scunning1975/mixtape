* Stata code attributed to Marcelo Perraillon.
ssc install rdrobust, replace
rdrobust score demvoteshare, c(0.5)
