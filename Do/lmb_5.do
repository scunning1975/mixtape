* Use all the data but interact the treatment variable with the running variable and a quadratic
gen demvoteshare_sq = demvoteshare_c^2
xi: reg score lagdemocrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
xi: reg score democrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
xi: reg democrat lagdemocrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
