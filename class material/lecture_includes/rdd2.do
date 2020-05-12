* Compare to previous equation
* gen y1 = 100 + 0*D + 2*x + rnormal(0, 20)

gen y = 100 + 80*D + 2*x + rnormal(0, 20)

scatter y x if D==0, msize(vsmall) || ///
  scatter y x if D==1, msize(vsmall)

msize(vsmall) legend(off) xline(140, ///
  lstyle(foreground)) || lfit y x if ///
  D ==0, color(red) || lfit y x if D==1, ///
  color(red) ytitle("Outcome (Y)")  ///
  xtitle("Test Score (X)") 
