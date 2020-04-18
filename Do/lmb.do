* name: lmb.do
* section: regression discontinuity

* Load the raw data into memory
use https://github.com/scunning1975/mixtape/raw/master/lmb-data.dta, clear

* Replicating Table 1 of Lee, Moretti and Butler (2004)
reg score lagdemocrat    if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg score democrat       if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)
reg democrat lagdemocrat if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id)

* Use all the data
reg score lagdemocrat, cluster(id)
reg score democrat, cluster(id)
reg democrat lagdemocrat, cluster(id)

* Re-center the running variable (voteshare)
gen demvoteshare_c = demvoteshare - 0.5
reg score lagdemocrat demvoteshare_c, cluster(id)
reg score democrat demvoteshare_c, cluster(id)
reg democrat lagdemocrat demvoteshare_c, cluster(id)

* Use all the data but interact the treatment variable with the running variable
xi: reg score i.lagdemocrat*demvoteshare_c, cluster(id)
xi: reg score i.democrat*demvoteshare_c, cluster(id)
xi: reg democrat i.lagdemocrat*demvoteshare_c, cluster(id)

* Use all the data but interact the treatment variable with the running variable and a quadratic
gen demvoteshare_sq = demvoteshare_c^2
xi: reg score lagdemocrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
xi: reg score democrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)
xi: reg democrat lagdemocrat##c.(demvoteshare_c demvoteshare_sq), cluster(id)

* Use 5 points from the cutoff
xi: reg score lagdemocrat##c.(demvoteshare_c demvoteshare_sq)   if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)
xi: reg score democrat##c.(demvoteshare_c demvoteshare_sq)       if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)
xi: reg democrat lagdemocrat##c.(demvoteshare_c demvoteshare_sq) if lagdemvoteshare>.45 & lagdemvoteshare<.55, cluster(id)

* Nonparametric histograms using cmogram
ssc install cmogram
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) qfitci
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) lfit

* Note kernel-weighted local polynomial regression is a smoothing method.
lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0 sdem0) bwidth(0.1)}
lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1 sdem1)  bwidth(0.1)}
scatter sdem1 x1, color(red) msize(small) || scatter sdem0 x0, msize(small) ///
color(red) xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score")}

* Local polynomial point estimators with bias correction
ssc install rdrobust
rdrobust score demvoteshare, c(0.5)

* McCrary density test
net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity demvoteshare, c(0.5) plot
DCdensity demvoteshare_c if (demvoteshare_c>-0.5 & demvoteshare_c<0.5), breakpoint(0) generate(Xj Yj r0 fhat se_fhat)
