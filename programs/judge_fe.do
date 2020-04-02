******************************************************
* name: judge_fe.do
* section: instrumental variables
******************************************************

capture log close
cap n estimates clear
use https://github.com/scunning1975/mixtape/raw/master/judge_fe.dta, clear
 
global judge_pre 	judge_pre_1 judge_pre_2 judge_pre_3 judge_pre_4 judge_pre_5 judge_pre_6 judge_pre_7 judge_pre_8
global demo 		black age male white 
global off  		fel mis sum F1 F2 F3 F M1 M2 M3 M 
global prior   		priorCases priorWI5 prior_felChar  prior_guilt onePrior threePriors
global control2 	day day2 day3  bailDate t1 t2 t3 t4 t5 t6




* Naive OLS

* minimum controls
cap n local specname=`specname'+1
reg guilt jail3 $control2, robust
cap n estadd ysumm
cap n estimates store dd_`specname'

* maximum controls
cap n local specname=`specname'+1
reg guilt jail3 possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 , robust
cap n estadd ysumm
cap n estimates store dd_`specname'



** Instrumental variables estimation
* 2sls main results

* minimum controls
cap n local specname=`specname'+1
ivregress 2sls guilt (jail3= $judge_pre) $control2, robust
cap n estadd ysumm
cap n estimates store dd_`specname'

* maximum controls
cap n local specname=`specname'+1
ivregress 2sls guilt (jail3= $judge_pre) possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 , robust
cap n estadd ysumm
cap n estimates store dd_`specname'


* JIVE main results
* minimum controls
cap n local specname=`specname'+1
jive guilt (jail3= $judge_pre) $control2, robust
cap n estadd ysumm
cap n estimates store dd_`specname'

* maximum controls
cap n local specname=`specname'+1
jive guilt (jail3= $judge_pre) possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 , robust
cap n estadd ysumm
cap n estimates store dd_`specname'


#delimit ;
	cap n estout * using ./judge_fe.tex, 
		style(tex) label notype margin 
		cells((b(star fmt(%9.3f) pvalue(p))) (se(fmt(%9.3f)par))) 		
		stats(N ymean,
			labels("N" "Mean of dependent variable")
			fmt(%9.0fc 2))
		keep(jail3)
		order(jail3)
		varlabels(jail3 "Detention")
		replace noabbrev starlevels(* 0.10 ** 0.05 *** 0.01) 
		title(OLS and IV Estimates of Detention on Guilty Plea)   
		collabels(none) eqlabels(none) mlabels(none) mgroups(none) 
		prehead("\begin{table}[htbp]\centering" "\footnotesize" "\caption{@title}" "\label{screening}" "\begin{center}" "\begin{threeparttable}" "\begin{tabular}{l*{@E}{c}}"
"\toprule"
"\multicolumn{1}{l}{Model:}&"
"\multicolumn{2}{c}{\textbf{OLS}}&"
"\multicolumn{2}{c}{\textbf{2SLS}}&"
"\multicolumn{2}{c}{\textbf{JIVE}}\\")
		posthead("\midrule")
		prefoot("\\" "\midrule")  
		postfoot("\bottomrule" "\end{tabular}" "\begin{tablenotes}" "\tiny" "\item First model includes controls for time; second model controls for characteristics of the defendant.  Outcome is guilty plea.  Heteroskedastic robust standard errors in parenthesis.  * p$<$0.10, ** p$<$0.05, *** p$<$0.01" "\end{tablenotes}" "\end{threeparttable}" "\end{center}" "\end{table}");
#delimit cr

cap n estimates clear


* Emily's test

testjfespline guilt jail3 $judge_pre, numknots(5) fitweight(1)
			
capture log close
exit



* Balance test
foreach y in possess robbery DUI1st drugSell aggAss $demo $prior $off   {
    ivregress 2sls `y' (jail3=$judge_pre) $control2, robust
    jive `y' (jail3=$judge_pre) $possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2, robust
}

* From Peter Hull's page. I do not get even close to the right numbers, so I'm ignoring it and the first stage completely.
* F1 = [(N − 2)Rˆ2] / (1−Rˆ2)
* FˆK = [(N − K − 1)Rˆ2] / [K(1 − Rˆ2)]
* 	  = [N − K − 1] / [K(N − 2)] * F1
* F={\frac  {\left({\frac  {{\text{RSS}}_{1}-{\text{RSS}}_{2}}{p_{2}-p_{1}}}\right)}{\left({\frac  {{\text{RSS}}_{2}}{n-p_{2}}}\right)}},

** This first stage is wrong.  Need to use Peter's calculations but I can't get anything close to right.
* minimum controls
reg jail3 $judge_pre $control2, robust
test $judge_pre
* maximum controls
reg jail3 $judge_pre $possess robbery DUI1st drugSell aggAss $demo $prior $off  $control2 , robust
test $judge_pre
