use https://github.com/scunning1975/mixtape/raw/master/judge_fe.dta, clear
 
global judge_pre judge_pre_1 judge_pre_2 judge_pre_3 judge_pre_4 judge_pre_5 judge_pre_6 judge_pre_7 judge_pre_8
global demo black age male white 
global off  	fel mis sum F1 F2 F3 F M1 M2 M3 M 
global prior priorCases priorWI5 prior_felChar  prior_guilt onePrior threePriors
global control2 	day day2 day3  bailDate t1 t2 t3 t4 t5 t6


* Naive OLS
* minimum controls
reg guilt jail3 $control2, robust
* maximum controls
reg guilt jail3 possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 , robust


* First stage
reg jail3 $judge_pre $control2, robust
reg jail3 possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 $judge_pre, robust



** Instrumental variables estimation
* 2sls main results
* minimum controls
ivregress 2sls guilt (jail3= $judge_pre) $control2, robust first
* maximum controls
ivregress 2sls guilt (jail3= $judge_pre) possess robbery DUI1st drugSell aggAss $demo $prior $off $control2 , robust first

* JIVE main results
* minimum controls
jive guilt (jail3= $judge_pre) $control2, robust
* maximum controls
jive guilt (jail3= $judge_pre) possess robbery DUI1st drugSell aggAss $demo $prior $off $control2 , robust
