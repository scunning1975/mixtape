* Use all the data but interact the treatment variable with the running variable
xi: reg score i.lagdemocrat*demvoteshare_c, cluster(id)
xi: reg score i.democrat*demvoteshare_c, cluster(id)
xi: reg democrat i.lagdemocrat*demvoteshare_c, cluster(id)
