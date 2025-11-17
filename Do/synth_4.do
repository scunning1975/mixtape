local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32 
	33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55
 foreach i of local statelist {
 	use ../data/synth/synth_bmprate_`i' ,clear
 	keep _Y_treated _Y_synthetic _time
 	drop if _time==.
	rename _time year
 	rename _Y_treated  treat`i'
 	rename _Y_synthetic counterfact`i'
 	gen gap`i'=treat`i'-counterfact`i'
 	sort year 
 	save ../data/synth/synth_gap_bmprate`i', replace
	}
use ../data/synth/synth_gap_bmprate48.dta, clear
sort year
save ../data/synth/placebo_bmprate48.dta, replace

foreach i of local statelist {
		merge year using ../data/synth/synth_gap_bmprate`i' 
		drop _merge 
		sort year 
	save ../data/synth/placebo_bmprate.dta, replace 
	}
	
