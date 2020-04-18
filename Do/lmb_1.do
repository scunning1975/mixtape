use https://github.com/scunning1975/mixtape/raw/master/lmb-data.dta, clear

* Replicating Table 1 of Lee, Moretti and Butler (2004)
reg score lagdemocrat    if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg score democrat       if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg democrat lagdemocrat if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
