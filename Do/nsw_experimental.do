use https://github.com/scunning1975/mixtape/raw/master/nsw_mixtape.dta, clear
su re78 if treat
gen y1 = r(mean)
su re78 if treat==0
gen y0 = r(mean)
gen ate = y1-y0
su ate
di 6349.144 - 4554.801
* ATE is 1794.34 
drop if treat==0
drop y1 y0 ate
compress
