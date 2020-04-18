cd /users/scott\_cunningham/downloads/texas/do
* Estimation 1: Texas model of black male prisoners (per capita) 
use https://github.com/scunning1975/mixtape/raw/master/texas.dta, clear
ssc install synth 
ssc install mat2txt
#delimit; 
synth 	bmprison  
			bmprison(1990) bmprison(1992) bmprison(1991) bmprison(1988)
			alcohol(1990) aidscapita(1990) aidscapita(1991) 
			income ur poverty black(1990) black(1991) black(1992) 
			perc1519(1990)
			,		
		trunit(48) trperiod(1993) unitnames(state) 
		mspeperiod(1985(1)1993) resultsperiod(1985(1)2000)
		keep(../data/synth/synth\_bmprate.dta) replace fig;
		mat list e(V_matrix);
		#delimit cr
		graph save Graph ../Figures/synth\_tx.gph, replace}
