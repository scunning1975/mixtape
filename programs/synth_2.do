* Plot the gap in predicted error
use ../data/synth/synth_bmprate.dta, clear
keep _Y_treated _Y_synthetic _time
drop if _time==.
rename _time year
rename _Y_treated  treat
rename _Y_synthetic counterfact
gen gap48=treat-counterfact
sort year
#delimit ; 
twoway (line gap48 year,lp(solid)lw(vthin)lcolor(black)), yline(0, lpattern(shortdash) lcolor(black)) 
	xline(1993, lpattern(shortdash) lcolor(black)) xtitle("",si(medsmall)) xlabel(#10) 
	ytitle("Gap in black male prisoner prediction error", size(medsmall)) legend(off); 
	#delimit cr
	save ../data/synth/synth_bmprate_48.dta, replace}