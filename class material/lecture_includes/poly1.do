capture drop y x2 x3

gen x2 = x*x
gen x3 = x*x*x
gen y = 10000 + 0*D - 100*x +x2 + rnormal(0, 1000)

reg y D x x2 x3
predict yhat 

scatter y x if D==0, msize(vsmall) || scatter y x 
  if D==1, msize(vsmall) legend(off) xline(140, 
  lstyle(foreground)) ylabel(none) || line yhat x 
  if D ==0, color(red) sort || line yhat x if D==1, 
  sort color(red) xtitle("Test Score (X)") 
  ytitle("Outcome (Y)") 
