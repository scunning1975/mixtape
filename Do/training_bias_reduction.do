use https://github.com/scunning1975/mixtape/raw/master/training_bias_reduction.dta, clear
reg Y X
gen muhat = _b[_cons] + _b[X]*X
list
