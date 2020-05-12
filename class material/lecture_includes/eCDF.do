bysort d: cumul y , gen(cum)
twoway (line cum y if d==1) ///
(line cum y if d==0, ///
lcolor(blue) lwidth(medium) ///
lpattern(dash)), title(eCDF) ///
legend(order(1 "Treatment" 2 "Control"))
