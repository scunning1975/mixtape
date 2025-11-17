clear 
set seed 1234
set obs 10
gen x = 9*rnormal() 
gen u  = 36*rnormal() 
gen y  = 3 + 2*x + u
reg y x
predict yhat
predict residuals, residual
su residuals
list
collapse (sum) x u y yhat residuals
list
