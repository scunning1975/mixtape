xi: xtreg l_homicide  i.year $region $xvar $lintrend post [aweight=popwt], fe vce(cluster sid)

local DDL = _b[post]
local DD : display %03.2f _b[post]
local DDSE : display %03.2f _se[post]
local DD1 = -0.10

xi: xtreg l_homicide  i.year $region lead9 lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 lag1-lag5 [aweight=popwt], fe vce(cluster sid)

outreg2 using "./eventstudy_levels.xls", replace keep(lead9 lead8 lead7 lead6 lead5 lead4 lead3 lead2 lead1 lag1-lag5) noparen noaster addstat(DD, `DD', DDSE, `DDSE')


*Pull in the ES Coefs
xmluse "./eventstudy_levels.xls", clear cells(A3:B32) first
replace VARIABLES = subinstr(VARIABLES,"lead","",.)	
replace VARIABLES = subinstr(VARIABLES,"lag","",.)	
quietly destring _all, replace ignore(",")
replace VARIABLES = -9 in 2
replace VARIABLES = -8 in 4
replace VARIABLES = -7 in 6
replace VARIABLES = -6 in 8
replace VARIABLES = -5 in 10
replace VARIABLES = -4 in 12
replace VARIABLES = -3 in 14
replace VARIABLES = -2 in 16
replace VARIABLES = -1 in 18
replace VARIABLES = 1 in 20
replace VARIABLES = 2 in 22
replace VARIABLES = 3 in 24
replace VARIABLES = 4 in 26
replace VARIABLES = 5 in 28
drop in 1
compress
quietly destring _all, replace ignore(",")
compress



ren VARIABLES exp
gen b = exp<.
replace exp = -9 in 2 
replace exp = -8 in 4
replace exp = -7 in 6
replace exp = -6 in 8
replace exp = -5 in 10 
replace exp = -4 in 12
replace exp = -3 in 14
replace exp = -2 in 16
replace exp = -1 in 18
replace exp = 1 in 20
replace exp = 2 in 22
replace exp = 3 in 24
replace exp = 4 in 26
replace exp = 5 in 28

* Expand the dataset by one more observation so as to include the comparison year
local obs =_N+1
set obs `obs'
for var _all: replace X = 0 in `obs'
replace b = 1 in `obs'
replace exp = 0 in `obs'
keep exp l_homicide b 
set obs 30
foreach x of varlist exp l_homicide b {
	replace `x'=0 in 30
	}
reshape wide l_homicide, i(exp) j(b)


* Create the confidence intervals
cap drop *lb* *ub*
gen lb = l_homicide1 - 1.96*l_homicide0 
gen ub = l_homicide1 + 1.96*l_homicide0 


* Create the picture
set scheme s2color
#delimit ;
twoway (scatter l_homicide1 ub lb exp , 
		lpattern(solid dash dash dot dot solid solid) 
		lcolor(gray gray gray red blue) 
		lwidth(thick medium medium medium medium thick thick)
		msymbol(i i i i i i i i i i i i i i i) msize(medlarge medlarge)
		mcolor(gray black gray gray red blue) 
		c(l l l l l l l l l l l l l l l) 
		cmissing(n n n n n n n n n n n n n n n n) 
		xline(0, lcolor(black) lpattern(solid))
		yline(0, lcolor(black)) 
		xlabel(-9 -8 -7 -6 -5 -4 -3 -2 -1 0 1 2 3 4 5 , labsize(medium))
		ylabel(, nogrid labsize(medium))
		xsize(7.5) ysize(5.5) 			
		legend(off)
		xtitle("Years before and after castle doctrine expansion", size(medium))
		ytitle("Log Murders ", size(medium))
		graphregion(fcolor(white) color(white) icolor(white) margin(zero))
		yline(`DDL', lcolor(red) lwidth(thick)) text(`DD1' -0.10 "DD Coefficient = `DD' (s.e. = `DDSE')")
		)
		;

#delimit cr;
