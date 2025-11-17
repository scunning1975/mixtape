* Examples using simulated data
set obs 1000
set seed 1234567

* Generate running variable
gen x = rnormal(100, 50)
replace x=0 if x < 0
drop if x > 280
sum x, det

* Set the cutoff at X=140. Treated if X > 140
gen D = 0
replace D = 1 if x > 140

gen y1 = 100 + 0*D + 2*x + rnormal(0, 20)
scatter y1 x if D==0, msize(vsmall) || scatter y1 x if D==1,  ///
  msize(vsmall) legend(off) xline(140, lstyle(foreground)) || ///
  lfit y1 x if D ==0, color(red) || lfit y1 x if D ==1, ///
  color(red) ytitle("Outcome (Y)")  xtitle("Test Score (X)") 
