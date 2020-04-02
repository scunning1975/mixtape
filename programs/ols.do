set seed 1 
clear 
set obs 10000 
gen x = rnormal() 
gen u  = rnormal() 
gen y  = 5.5*x + 12*u 
reg y x 
predict yhat1 
gen yhat2 = -0.0750109  + 5.598296*x // Compare yhat1 and yhat2
sum yhat* 
predict uhat1, residual 
gen uhat2=y-yhat2 
sum uhat* 
twoway (lfit y x, lcolor(black) lwidth(medium)) (scatter y x, mcolor(black) ///
msize(tiny) msymbol(point)), title(OLS Regression Line) 
rvfplot, yline(0) 
