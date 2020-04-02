clear
capture log close
set obs 1000
set seed 1234567

* Generate running variable
gen x = rnormal(50, 25)
replace x=0 if x < 0
drop if x > 100
sum x, det

* Set the cutoff at X=50. Treated if X > 50
gen D = 0
replace D = 1 if x > 50
gen y1 = 25 + 0*D + 1.5*x + rnormal(0, 20)

* Potential outcome Y1 not jumping at cutoff (continuity)
twoway (scatter y1 x if D==0, msize(vsmall) msymbol(circle_hollow)) (scatter y1 x if D==1, sort mcolor(blue) msize(vsmall) msymbol(circle_hollow)) (lfit y1 x if D==0, lcolor(red) msize(small) lwidth(medthin) lpattern(solid)) (lfit y1 x, lcolor(dknavy) msize(small) lwidth(medthin) lpattern(solid)), xtitle(Test score (X)) xline(50) legend(off)

