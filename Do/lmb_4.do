* Stata code attributed to Marcelo Perraillon.
xi: reg score i.lagdemocrat*demvoteshare_c, cluster(id)
xi: reg score i.democrat*demvoteshare_c, cluster(id)
xi: reg democrat i.lagdemocrat*demvoteshare_c, cluster(id)
