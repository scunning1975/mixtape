* Stata code attributed to Marcelo Perraillon.
gen demvoteshare_c = demvoteshare - 0.5
reg score lagdemocrat demvoteshare_c, cluster(id)
reg score democrat demvoteshare_c, cluster(id)
reg democrat lagdemocrat demvoteshare_c, cluster(id)
