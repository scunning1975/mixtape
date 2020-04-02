* Inference 1 placebo test  
#delimit; 
set more off; 
use ../data/texas.dta, replace; 
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32  
	33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55; 
foreach i of local statelist {;
synth 	bmprison  
		bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988) 
		alcohol(1990) aidscapita(1990) aidscapita(1991)  
		income ur poverty black(1990) black(1991) black(1992)  
		perc1519(1990) 
		,		 
			trunit(`i') trperiod(1993) unitnames(state)  
			mspeperiod(1985(1)1993) resultsperiod(1985(1)2000) 
			keep(../data/synth/synth\_bmprate\_`i'.dta) replace; 
			matrix state`i' = e(RMSPE); /* check the V matrix*/ 

foreach i of local statelist {; 
matrix rownames state`i'=`i'; 
matlist state`i', names(rows); 
};
#delimit cr
