* show post/pre-expansion RMSPE ratio for all states, generate histogram
	foreach i of local statelist {
		matrix rownames state`i'=`i'
		matlist state`i', names(rows)
									}
#delimit ;
matstate=state1/state2/state4/state5/state6/state8/state9/state10/state11/state12/state13/state15/state16/state17/state18/state20/state21/state22/state23/state24/state25/state26/state27/state28/state29/state30/state31/state32/state33/state34/state35/state36/state37/state38/state39/state40/state41/state42/state45/state46/state47/state48/state49/state51/state53/state55; 
#delimit cr
* ssc install mat2txt
	mat2txt, matrix(state) saving(../inference/rmspe_bmprate.txt) replace
	insheet using ../inference/rmspe_bmprate.txt, clear
	ren v1 state
	drop v5
	gsort -ratio
	gen rank=_n
	gen p=rank/46
	export excel using ../inference/rmspe_bmprate, firstrow(variables) replace
	import excel ../inference/rmspe_bmprate.xls, sheet("Sheet1") firstrow clear
	histogram ratio, bin(20) frequency fcolor(gs13) lcolor(black) ylabel(0(2)6) 
	xtitle(Post/pre RMSPE ratio) xlabel(0(1)5)
* Show the post/pre RMSPE ratio for all states, generate the histogram.
	list rank p if state==48
