********************************************************************************
* NAME:   lmb2004.do
* DESCRIPTION: Illustration of Regression Discontinuty Analysis of Lee, Moretti
*			   and Butler 2004 QJE (http://business.baylor.edu/scott%5Fcunningham/teaching/lee-et-al-2004.pdf)
* LAST UPDATED: April 24, 2014
********************************************************************************

clear
set more off, perm
capture log close

* You will need to change the next line so that STATA ``chooses directory'' on your
* computer.  You can find this by pulling down FILE and choosing ``Change working
* directory'' and then selecting the appropriate work directory. 

cd "/Users/scott_cunningham/Dropbox/Classes/Causality and Research Design/Workshops/Stata workshop/RDD/EITM-RD-Examples"

* You'll need these programs; comment out once you've downloaded it
* ssc install cmogram, replace
* ssc install rd, replace
* net install rdrobust, from(http://www-personal.umich.edu/~cattaneo/rdrobust/stata) replace


/*
You will also need to install McCrary's DCdensity.ado package and unfortunately 
you can't use the "ssc install" or "net install" commands to do so.  So, here 
are your instructions.  Here are the instructions: 

http://eml.berkeley.edu/~jmccrary/DCdensity/README

1. First download the ado file from McCrary's website. Pay attention to where it downloads
as we are going to be moving it.

http://emlab.berkeley.edu/~jmccrary/DCdensity/DCdensity.ado

2.  Next, put the DCdensity.ado file in your ado folder.  If you don't know where your ado 
folder is, issue -sysdir- from the STATA prompt and it will tell you.  Mine is:

. sysdir
   STATA:  /Applications/Stata/
    BASE:  /Applications/Stata/ado/base/
    SITE:  /Applications/Stata/ado/site/
    PLUS:  ~/Library/Application Support/Stata/ado/plus/
PERSONAL:  ~/Library/Application Support/Stata/ado/personal/
OLDPLACE:  ~/ado/

So I will be moving the .ado package to /Library/Application Support/Stata/ado/personal and put
it into the appropriable alphabetized subdirectory (d).  

3.  Note that you will likely have to make your ~/Library folder visible in order 
to do this, which you can do from Terminal by typing "open ~/Library".  

4.  Now move DCdensity.ado into the correct subdirectory.
*/

capture log using ./lmb2004, replace


/*-------------------------------------------------------------------------*/
* Example: Lee, Moretti, and Butler (2004)
/*-------------------------------------------------------------------------*/

* Download and install their data from my website:

use http://business.baylor.edu/scott_cunningham/teaching/lmb-data.dta, replace
 
* I changed the label of some unlabeled variables for easier interpretation later
label variable score "ADA Score, time t"
label variable lagscore "ADA score, time t-1"
label variable democrat "Probability of Democrat win, time t"
label variable lagdemocrat "Probability of Democrat win, time t-1"
label variable lagdemvoteshare "Democratic vote share, time t-1"

* Produce Results by OLS
* Table 1: Results Based on ADA Scores - Close Elections Sample
reg   score lagdemocrat    if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id2)
reg   score democrat 	   if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id2)
reg   democrat lagdemocrat if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id2)

* Equation 1: regresses ADA score in time t on the t-1 binary lagged democrat variable (election outcome)
* Equation 2: regresses ADA score in time t on contemporaneous democrat variable (election outcome)
* Equation 3: regresses whether the candidate won against whether she won in t-1. 

* All regressions use only the lagged democrat voteshare between 0.48 and 0.52 (i.e., +/- 0.02 around the cutoff)
* Note, the 3rd regression above is effectively the one challenged by Caughey and Sekhon


* Examine variations in model specification
* Figure IIa: Effect of Party Affiliation on ADA scores in time t.

* Center vote share at 50% to improve interpretation in interaction models
gen 	  demvoteshare_c = demvoteshare - 0.5

* Raw difference using all the data.  Note this is not a discontinuity regression because
* unlike equation 2 above, we are using _all_ the data and not just the data around the
* discontinuity.  
reg       score democrat , cluster(id2)

* versus

reg       score democrat 	   if lagdemvoteshare>.48 & lagdemvoteshare<.52, cluster(id2)

* Next, control for the (centered) running variable which is a linear control variable.  
* This is the simplest RDD. 
reg   	  score  democrat demvoteshare_c, cluster(id2)

* Modeling the linearity such that slopes can differ above vs. below the discontinuity 
xi: reg   score i.democrat*demvoteshare_c, cluster(id2)


* Narrow bandwidth (this is local linear regression)
xi: reg   score i.democrat*demvoteshare_c if demvoteshare>.40 & demvoteshare<.60, cluster(id2)
xi: reg   score i.democrat*demvoteshare_c if demvoteshare>.45 & demvoteshare<.55, cluster(id2)
xi: reg   score i.democrat*demvoteshare_c if demvoteshare>.48 & demvoteshare<.52, cluster(id2)
xi: reg   score i.democrat*demvoteshare_c if demvoteshare>.49 & demvoteshare<.51, cluster(id2)

* Notice the standard errors are growing as we move closer to the cutoff.  Notice the
* number of observations is falling as we limit our sample to only units in h proximity
* to the cutoff.

* Narrow bandwidth, no vote share control (this is comparing means close to cutoff)
reg   score democrat if demvoteshare>.49 & demvoteshare<.51, cluster(id2)


* GETTING STARTED WITH PICTURES. 
* First let's just look at the raw data.  Compare this figure with Figure IIA from their paper.  What's different?
scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ytitle("ADA score")

* Add the "jitter" option so you can better see where the mass is.  Does this help?  Still not Figure IIA though...
scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ytitle("ADA score") jitter(5)

* We could add the linear trends
scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ytitle("ADA score") || lfit score demvoteshare if democrat==1, color(red) || lfit score demvoteshare if democrat==0, color(red) legend(off) jitter(5)

* What about a polynomial of degree 5?
gen demvoteshare2=demvoteshare^2
gen demvoteshare3=demvoteshare^3
gen demvoteshare4=demvoteshare^4
gen demvoteshare5=demvoteshare^5
reg score demvoteshare demvoteshare2 demvoteshare3 demvoteshare4 demvoteshare5 demvoteshare5 democrat, cluster(id2)
predict scorehat

scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democratic vote share") ytitle("ADA score") || line scorehat demvoteshare if democrat==1, sort color(red) || line scorehat demvoteshare if democrat==0, sort color(red) legend(off)
graph export ./lmb3.png, replace

* Center the forcing variable and use polynomials and interactions to model the nonlinearities below and above.
gen 	x_c=demvoteshare-0.5
gen 	x2_c=x_c^2
gen 	x3_c=x_c^3
gen 	x4_c=x_c^4
gen 	x5_c=x_c^5

reg score i.democrat##(c.x_c c.x2_c c.x3_c c.x4_c c.x5_c)

* We could restrict the regressions to a window by running a flexible regression,
* like a polynomial with interactions (stratified), but don't use observations away
* from the cutoff.  Choose a "bandwidth" around X=0.5.  Lee et al (2004) used 0.4 to
* 0.6 in their analysis.

reg score demvoteshare demvoteshare2 if democrat==1 & (demvoteshare>0.4 & demvoteshare<0.6)
predict scorehat1 if e(sample)

reg score demvoteshare demvoteshare2 if democrat==0 & (demvoteshare>0.4 & demvoteshare<0.6)
predict scorehat0 if e(sample)

scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ytitle("ADA score") || line scorehat1 demvoteshare if democrat==1, sort color(red) || line scorehat0 demvoteshare if democrat==0, sort color(red) legend(off)
graph export ./lmb3_1.png, replace

* We could limit the regressions to a window using a 2nd degree polynomial
reg score i.democrat##(c.x_c c.x2_c) if (demvoteshare>0.4 & demvoteshare<0.6)


* Hahn, Todd and Van der Klaauw (2001) clarified assumptions about RDD and framed
* estimation as a nonparametric problem. They emphasized using local polynomial 
* regressions.  

* Nonparametric methods means a lot of different things to different people in statistics.
* In the RDD context, the idea is to estimate a model that does not assume a functional
* form for the relationship between Y (dependent variable) and X (running variable).
* That model would be something general like: Y=f(X) + e.

* A very basic method: calculate E[Y] for each bin on X.  Like a histogram.
* STATA has a command to do just that called -cmogram-.  It has lots of useful 
* options and this is a common way to show RDD data.  To recreate something like
* Figure 1 of Lee et al (2004):
cmogram score lagdemvoteshare , cut(0.5) scatter line(0.5) qfit

* Compare this to linear and LOWESS fits:
cmogram score lagdemvoteshare , cut(0.5) scatter line(0.5) lfit
cmogram score lagdemvoteshare , cut(0.5) scatter line(0.5) lowess


* Figure IIa (Effect of Party Affiliation on ADA score)
* Made with -cmogram-
cmogram score demvoteshare, cut(.5) scatter line(.5) 
* Add linear fit on each side of cutoff without confidence intervals
cmogram score demvoteshare, cut(.5) scatter line(.5) lfit
* Add linear fit on each side of cutoff with confidence intervals
cmogram score demvoteshare, cut(.5) scatter line(.5) lfitci
* Add quadratic fit separately on each side of cutoff
cmogram score demvoteshare, cut(.5) scatter line(.5) qfitci

* Compare the difference in the vertical distance at the cutoff for the linear fit
* model and the quadratic fit model. Notice how the linear model is heavily influenced
* by the outliers that pull down the slope at higher values of demvoteshare.  As
* this is causing the regression slope coefficient to "pivot", notice how it causes the 
* highest point on the slope at the top left to rise. This is the sort of "bias"
* problem that we contend with in RDD.  


* Hahn, Todd and Van der Klaauw (2001) showed that the one-sided Kernel
* estimation (like LOWESS) may have poor properties because the point of interest
* is at a boundary (i.e., the cutoff).  This is teh "boundary problem".  They
* proposed instead to use a "local linear nonparametric regression"

* STATA's -lpoly- command eestimates kernel-weighted local polynomial regression
* Think of it as a weighted regression restricted to a window like we've been
* doing (and hence the reason it's called a "local" regression) where the Kernel
* provides the weights.  

* A rectangular Kernel would give the same result as taking E[Y] at a given bin
* on X.  The triangular Kernel gives more importance to observations close to the
* center.  

* This method is sensitive to your choice of the bandwidth (window).

* First, note that local regression is a smoothing method.  Here is a kernel-
* weighted local polynomial regression which you will see is a smoothing method.
lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0 sdem0)  ///
         bwidth(0.1)
lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1 sdem1)  ///
         bwidth(0.1)
scatter sdem1 x1, color(red) msize(small) || scatter sdem0 x0, msize(small) color(red) ///
     xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score")
graph export ./lmb_lpoly.png, replace

* Next, let's get the treatment effect at the cutoff where demvoteshare=0.5
capture drop sdem0 sdem1 
gen forat=0.5 in 1
lpoly score demvoteshare if democrat==0, nograph kernel(triangle) gen(sdem0) at(forat) bwidth(0.1)
lpoly score demvoteshare if democrat==1, nograph kernel(triangle) gen(sdem1) at(forat) bwidth(0.1)
gen late=sdem1 - sdem0
list sdem1 sdem0 late in 1/1


* What happens when we change the bandwidth? Use 0.01, 0.05, 0.2, 0.3, 0.4

capture drop smoothdem0* smoothdem1* x0* x1*

local co 0
foreach i in 0.01 0.05 0.1 0.20 0.30 0.40 {
   local co = `co' +1
   lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0`co' smoothdem0`co')  ///
         bwidth(`i')
   lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1`co' smoothdem1`co')  ///
         bwidth(`i')
}

line smoothdem01 x01, msize(small) color(gray) sort || line smoothdem11 x11, sort color(gray) || ///
     line smoothdem02 x02, color(black) sort || line smoothdem12 x12, sort color(black) || ///
     line smoothdem03 x03, color(red) sort || line smoothdem13 x13, sort color(red) || ///
     line smoothdem04 x04, color(blue) sort || line smoothdem14 x14, sort color(blue) || ///
	  line smoothdem05 x05, color(green)sort || line smoothdem15 x15, sort color(green)|| ///
	  line smoothdem06 x06, color(orange) sort || line smoothdem16 x16, sort  color(orange) ///
     xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score") ///
	  title("Bandwidths: 0.01, 0.05, 0.1, 0.2, 0.3, 0.4")
graph export ./lmb_dif_bws.png, replace
	  
* There's several methods to choose optimal windows: the trade off is between bias and variance
* In practical applications, you may want to check balance around that window.
* Standard error of treatment effect can be bootstrapped but there are also other
* alternatives. You could add other variables to nonparametric methods.  Here we will use
* local-polynomial regression discontinuity estimators with robust confidence intervals
* as proposed in Calonico, Cattaneao and Titiunik (2013b). The STATA ado package
* is -rdrobust-.  There is also an R package of the same name.

rdrobust score demvoteshare, c(0.5) all bwselect(IK)

* When would parametric or non-parametric or window size actually matter?
* 1. when there is a small effect,
* 2. when the relationship between Y and X is different away from the cutoff
* 3. when the functional form is not well captured by polynomials or other functional
*    forms.  Splines may work too.
* Easier to work with traditional methods (parametric)
* Could add random effects, robust standard errors, clustering standard errors
* In practical applications, a regression with polynomials usually works well
* But if the conclusiosn are different, worry.  A lot.

* Produce Results by nonparametric regression

* Use the Imbens & K optimal bandwidth estimator, rdob.ado

* rdob syntax
/* estimate rd effect */
/* y is outcome */
/* x is forcing variable */
/* z1, z2, z3 are additional covariates */
/* w is treatment indicator */
/* c(0.5) implies that threshold is 0.5 */

rdob score demvoteshare, c(0.5)

*Using optimal bandwidth from rdob estimation
rd score democrat demvoteshare if score!=. & demvoteshare!=., z0(.5) gr 


* McCrary (2008) density test to check for manipulation of the running variable (DCdensity)
capture drop Xj Yj r0 fhat se_fhat
DCdensity demvoteshare_c if (demvoteshare_c>-0.5 & demvoteshare_c<0.5), breakpoint(0) generate(Xj Yj r0 fhat se_fhat) graphname(./dbm_densitytest.eps)



********************************************************************************
* Think about how to do some of the Coughey and Sekhon (CS) analyses
* I do not have their code, so this is my approximation
* Also note that CS data have other differences relative to LMB, so we shouldn't 
* expect to reproduce their results exactly
********************************************************************************

* Make a version of Figures 1B and 1C
gen repvoteshare = 1-demvoteshare

cmogram score demvoteshare if lagdemocrat==1 & demvoteshare>.4 & demvoteshare<.6, cut(.5) scatter line(.5) count
cmogram score repvoteshare if lagdemocrat==0 & repvoteshare>.4 & repvoteshare<.6, cut(.5) scatter line(.5) count

* Make Figure 2
gen incvoteshare = .
	replace incvoteshare = demvoteshare if lagdemocrat==1
	replace incvoteshare = repvoteshare if lagdemocrat==0

cmogram score incvoteshare if incvoteshare>.4 & incvoteshare<.6, cut(.5) line(.5) count

* Now reproduce results from Covariate Imbalance Graph

ttest lagdemocrat if demvoteshare>.495 & demvoteshare<.505, by(democrat)
ttest lagdemvoteshare if demvoteshare>.495 & demvoteshare<.505, by(democrat)


* OK, you get the idea. Now try more on your own.
* Try making Figure 4 from CS


scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ytitle("ADA score")
graph export lee1.png, replace

* Graph 1.1: jittering
scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share")  ///
    ytitle("ADA score") jitter(2)
graph export lee1_1.png, replace


* Graph 2: Add linear trend
scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ///
        ytitle("ADA score") || ///
		  lfit score demvoteshare if democrat ==1, color(red) ||  ///
		  lfit score demvoteshare if democrat ==0, color(red) legend(off)
graph export lee2.png, replace

* Something more flexible is better 
gen demvoteshare2 = demvoteshare^2
gen demvoteshare3 = demvoteshare^3
gen demvoteshare4 = demvoteshare^4
gen demvoteshare5 = demvoteshare^5
reg score demvoteshare demvoteshare2 demvoteshare3 demvoteshare4 demvoteshare5 democrat
qui predict scorehat

scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ///
  ytitle("ADA score") || ///
  line scorehat demvoteshare if democrat ==1, sort color(red) || ///
  line scorehat demvoteshare if democrat ==0, sort color(red) legend(off) 
graph export lee3.png, replace

* Use winwdow and 2nd degree
reg score demvoteshare demvoteshare2 if democrat ==1 &  (demvoteshare>.40 & demvoteshare<.60)
predict scorehat1 if e(sample)
reg score demvoteshare demvoteshare2 if democrat ==0 &  (demvoteshare>.40 & demvoteshare<.60)
predict scorehat0 if e(sample)

scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ///
  ytitle("ADA score") || ///
  line scorehat1 demvoteshare if democrat ==1, sort color(red) || ///
  line scorehat0 demvoteshare if democrat ==0, sort color(red) legend(off) 
graph export lee3_1.png, replace
	 
* Do lowess 
capture drop lowess_y_d1 lowess_y_d0
lowess score demvoteshare if democrat ==1, gen (lowess_y_d1) nograph bw(0.5)
lowess score demvoteshare if democrat ==0, gen (lowess_y_d0) nograph bw(0.5)

scatter score demvoteshare, msize(tiny) xline(0.5) xtitle("Democrat vote share") ///
  ytitle("ADA score") || ///
  line lowess_y_d1 demvoteshare if democrat ==1, sort color(red) || ///
  line lowess_y_d0 demvoteshare if democrat ==0, sort color(red) legend(off) 
graph export lee4.png, replace

* Binned graph
cmogram score demvoteshare, cut(.5) scatter line(.5) qfit
graph export lee5.png, replace

* with linear plot
qui cmogram score demvoteshare, cut(.5) scatter line(.5) lfit 
graph save lin.gph, replace

* lowess smoothing
qui cmogram score demvoteshare, cut(.5) scatter line(.5) lowess 
graph save lowess.gph, replace

graph combine lin.gph lowess.gph, xcommon col(1)
graph export lin_low.png, replace

* Show regression results
gen x_c = demvoteshare - 0.5
gen x2_c = x_c^2
gen x3_c = x_c^3
gen x4_c = x_c^4
gen x5_c = x_c^5

* Use all obs
reg score i.democrat##(c.x_c c.x2_c c.x3_c c.x4_c c.x5_c)

* Restrict to window and drop some polynomials
reg score i.democrat##(c.x_c c.x2_c) if (demvoteshare>.40 & demvoteshare<.60)

* Better SEs with clustering
reg score i.democrat##(c.x_c c.x2_c) if (demvoteshare>.40 & demvoteshare<.60), cluster(id2)

// ----- Local regression (non-parametric)
* Graph using lpoly
capture drop sdem0 sdem1 x0 x1

drop sdem0
drop sdem1

lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0 sdem0)  ///
         bwidth(0.1)
lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1 sdem1)  ///
         bwidth(0.1)
scatter sdem1 x1, color(red) msize(small) || scatter sdem0 x0, msize(small) color(red) ///
     xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score")
graph export lee_lpoly.png, replace
			
					
* Could use rd or rd_obs but it's buggy
* Do it by hand using lpoly
gen forat = 0.5 in 1

capture drop sdem0 sdem1

lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(sdem0)  ///
       at(forat) bwidth(0.1)
lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(sdem1)  ///
       at(forat) bwidth(0.1)
gen dif = sdem1 - sdem0
list sdem1 sdem0 dif in 1/1

* Use command rd (the older version, rd_obs)
qui reg score democrat demvoteshare 
gen sample = 1 if e(sample)

rd_obs score democrat demvoteshare if sample, z0(0.5) bwidth(0.10) 
	
* Show different windows
capture drop smoothdem0* smoothdem1* x0* x1*

local co 0
foreach i in 0.01 0.05 0.1 0.20 0.30 0.40 {
   local co = `co' +1
   lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0`co' smoothdem0`co')  ///
         bwidth(`i')
   lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1`co' smoothdem1`co')  ///
         bwidth(`i')
}

line smoothdem01 x01, msize(small) color(gray) sort || line smoothdem11 x11, sort color(gray) || ///
     line smoothdem02 x02, color(black) sort || line smoothdem12 x12, sort color(black) || ///
     line smoothdem03 x03, color(red) sort || line smoothdem13 x13, sort color(red) || ///
     line smoothdem04 x04, color(blue) sort || line smoothdem14 x14, sort color(blue) || ///
	  line smoothdem05 x05, color(green)sort || line smoothdem15 x15, sort color(green)|| ///
	  line smoothdem06 x06, color(orange) sort || line smoothdem16 x16, sort  color(orange) ///
     xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score") ///
	  title("Bandwidths: 0.01, 0.05, 0.1, 0.2, 0.3, 0.4")
graph export lee_dif_bws.png, replace
	  
* rectangular kernel
capture drop smoothdem0* smoothdem1* x0* x1*

local co 0
foreach i in 0.01 0.05 0.1 0.20 0.30 0.5 {
   local co = `co' +1
   lpoly score demvoteshare if democrat == 0, nograph kernel(rec) gen(x0`co' smoothdem0`co')  ///
         bwidth(`i')
   lpoly score demvoteshare if democrat == 1, nograph kernel(rec) gen(x1`co' smoothdem1`co')  ///
         bwidth(`i')
}

line smoothdem01 x01, msize(small) color(gray) sort || line smoothdem11 x11, sort msize(small) color(gray) || ///
     line smoothdem02 x02, msize(small) color(black) sort || line smoothdem12 x12, sort msize(small) color(black) || ///
     line smoothdem03 x03, msize(small) color(red) sort || line smoothdem13 x13, sort msize(small) color(red) || ///
     line smoothdem04 x04, msize(small) color(blue) sort || line smoothdem14 x14, sort msize(small) color(blue) || ///
	  line smoothdem05 x05, msize(small) color(green)sort || line smoothdem15 x15, sort msize(small) color(green)|| ///
	  line smoothdem06 x06, msize(small) color(orange) sort || line smoothdem16 x16, sort msize(small) color(orange) ///
     xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score") ///
	  title("Bandwidths: 0.01, 0.05, 0.1, 0.2, 0.3, 0.5")
graph export lee_dif_bws_rec.png, replace
	  
	  
* Try the new command
rdrobust score demvoteshare, c(0.5) h(0.1)
rdrobust score demvoteshare, c(0.5) bwselect(IK)
rdrobust score demvoteshare, c(0.5) all bwselect(CCT)
rdrobust score demvoteshare, c(0.5) all bwselect(IK)
 
