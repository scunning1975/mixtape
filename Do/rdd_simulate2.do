* Actual outcome jumping
gen y = 25 + 40*D + 1.5*x + rnormal(0, 20)
scatter y x if D==0, msize(vsmall) || scatter y x if D==1, msize(vsmall) legend(off) xline(50, lstyle(foreground)) || lfit y x if D ==0, color(red) || lfit y x if D ==1, color(red) ytitle("Outcome (Y)")  xtitle("Test Score (X)") 

