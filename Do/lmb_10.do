* McCrary density test. Stata code attributed to Marcelo Perraillon.
net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity demvoteshare, c(0.5) plot
