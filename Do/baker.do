********************************************************************************
* name: baker.do
* author: scott cunningham (baylor) adapting andrew baker (stanford)
* description: shows what a piece of shit TWFE is with differential timing and
*              heterogenous treatment effects over time
* last updated: april 17, 2020
********************************************************************************

clear
capture log close
set seed 20200403

* 1,000 firms (25 per state), 40 states, 4 groups (250 per groups), 30 years
* First create the states
set obs 40
gen state = _n

* Finally generate 1000 firms.  These are in each state. So 25 per state.
expand 25
bysort state: gen firms=runiform(0,5)
label variable firms "Unique firm fixed effect per state"

* Second create the years
expand 30
sort state
bysort state firms: gen year = _n
gen n=year
replace year = 1980 if year==1
replace year = 1981 if year==2
replace year = 1982 if year==3
replace year = 1983 if year==4
replace year = 1984 if year==5
replace year = 1985 if year==6
replace year = 1986 if year==7
replace year = 1987 if year==8
replace year = 1988 if year==9
replace year = 1989 if year==10
replace year = 1990 if year==11
replace year = 1991 if year==12
replace year = 1992 if year==13
replace year = 1993 if year==14
replace year = 1994 if year==15
replace year = 1995 if year==16
replace year = 1996 if year==17
replace year = 1997 if year==18
replace year = 1998 if year==19
replace year = 1999 if year==20
replace year = 2000 if year==21
replace year = 2001 if year==22
replace year = 2002 if year==23
replace year = 2003 if year==24
replace year = 2004 if year==25
replace year = 2005 if year==26
replace year = 2006 if year==27
replace year = 2007 if year==28
replace year = 2008 if year==29
replace year = 2009 if year==30
egen id =group(state firms)

* Add 250 firms treated every period with the treatment effect still 5 on average
* Cohort years 1986, 1992, 1998, 2004
su state, detail
gen     group=0
replace group=1 if state<=`r(p25)'
replace group=2 if state>`r(p25)' & state<=`r(p50)'
replace group=3 if state>`r(p50)' & state<=`r(p75)'
replace group=4 if state>`r(p75)' & `r(p75)'!=.
gen     treat_date = 0 
replace treat_date = 1986 if group==1
replace treat_date = 1992 if group==2
replace treat_date = 1998 if group==3
replace treat_date = 2004 if group==4
gen     treat=0  
replace treat=1 if group==1 & year>=1986
replace treat=1 if group==2 & year>=1992
replace treat=1 if group==3 & year>=1998
replace treat=1 if group==4 & year>=2004

* Data generating process
gen e 	= rnormal(0,(0.5)^2)
gen te1 = rnormal(10,(0.2)^2) 
gen te2 = rnormal(8,(0.2)^2)
gen te3 = rnormal(6,(0.2)^2)
gen te4 = rnormal(4,(0.2)^2)
gen te = .

replace te = te1 if group == 1
replace te = te2 if group == 2
replace te = te3 if group == 3
replace te = te4 if group == 4

* Cumulative treatment effect is te x (year - t_g + 1) -- Dynamic treatment effects over time for each group.
* How does (year - treat_date + 1) create dynamic ATT?  Assume treat_date is 1992 and it is year 2000. Then, te=8 x (2000 - 1992 + 1) = 8 x (9) = 72. Group 2's TE rises from an 8 up to 72 in the t+8 year.

* Data generating process with heterogeneity over time
gen y = firms + n + treat*te*(year - treat_date + 1) + e 

* Constant treatment effects.  Notice, the treatment effect is constant. 
gen y2 = firms + n + te*treat + e 


* Leads and lags
gen     time_til=year-treat_date
ta time_til, gen(dd)

* Estimation using TWFE - constant treatment effects
areg y2 i.year treat, a(id) robust 

* Estimation using TWFE - heterogenous treatment effects over time
areg y i.year treat, a(id) robust 

* Event study with heterogeneity.
areg y i.year dd1 - dd23 dd25-dd48, a(id) robust 

* Bacon decomposition shows the problem -- notice all those late to early 2x2s!
net install ddtiming, from(https://tgoldring.com/code/)
areg y i.year treat, a(id) robust
ddtiming y treat, i(id) t(year)


**************************************************************************************************************************************
**************************************************************************************************************************************
**************************************************************************************************************************************
* Callaway and Sant'anna (2018)
* When there are no coariates X and everybody eventually gets treated, Callaway & Sant'Anna (2018) suggest to estimate ATT(g,t) using
* ATT(g,t) = E [ (Gg/E[Gg] - ( 1-Dt)/E[1-Dt] )( Yt - Y_{g-1}) ]
**************************************************************************************************************************************
**************************************************************************************************************************************
**************************************************************************************************************************************

* Create group dummies
gen	g1=0
replace g1=1 if group==1

gen 	g2=0
replace g2=1 if group==2

gen 	g3=0
replace g3=1 if group==3

gen 	g4=0
replace g4=1 if group==4


**************************************************************************************************************************************
* Estimate propensity scores. 
* In this setup where there is no "never treated" group, we need propensity scores per time period. 
* We can exploit the staggered rollout to simplify this a bit!
* Since I only know how to work things out well in the "wide" data format instead of the "long" data format, I simplify things a bit!
* pscore for Group 1986 that can be used until year 1991 (since at 1992 another set of units get treated)
* Note that I am using only a single year of data (this is because I want to use "wide format".
**************************************************************************************************************************************
logit g1 if ((year==1991) & ((g1==1) | (time_til<0)))
predict pg1_1991 // pscore is 0.25 because there's four groups. 


**************************************************************************************************************************************
* Calculate ATT(1986,1986)
* This the the ATT for the group first treated at 1986 (g1==1) in the first period since treatment (1986)
* gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1986
gen ypre = y if year==1985
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant
bysort year: egen g1_mean = mean(g1)
bysort year: egen g1_cont_1991mean = mean((1 - g1)*pg1_1991/(1 - pg1_1991))


**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = ((1 - g1)*pg1_1991/(1 - pg1_1991))/g1_cont_1991mean
* Generate each component of the DID
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

* Get the ATT(1986,1986)
gen att1986_1986 = (att_11-att_10) -(att_01 -att_00)
* ATT(1986,1986)=10.00096

* Drop variable so I can copy paste this code!
drop ypost ypre g1_mean g1_cont_1991mean w1 w0 att_*


**************************************************************************************************************************************
* Calculate ATT(1986,1987)
* This the the ATT for the group first treated at 1986 (g1==1) in the second period since treatment (1987)
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1987
gen ypre = y if year==1985
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant in this subset of data!
bysort year: egen g1_mean = mean(g1)
bysort year: egen g1_cont_1991mean = mean((1 - g1)*pg1_1991/(1 - pg1_1991))

**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = ((1 - g1)*pg1_1991/(1 - pg1_1991))/g1_cont_1991mean

**************************************************************************************************************************************
* Generate each component of the DID
**************************************************************************************************************************************
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

**************************************************************************************************************************************
* Get the ATT(1986,1987)
**************************************************************************************************************************************
gen att1986_1987 = (att_11-att_10) -(att_01 -att_00)
* ATT(1986,1987)=19.96895
* Drop variable so I can copy paste this code!
**************************************************************************************************************************************
drop ypost ypre g1_mean g1_cont_1991mean w1 w0 att_*



**************************************************************************************************************************************
* Calculate ATT(1986,1988)
* This the the ATT for the group first treated at 1986 (g1==1) in the third period since treatment (1988)
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1988
gen ypre = y if year==1985
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant in this subset of data!
bysort year: egen g1_mean = mean(g1)
bysort year: egen g1_cont_1991mean = mean((1 - g1)*pg1_1991/(1 - pg1_1991))

**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = ((1 - g1)*pg1_1991/(1 - pg1_1991))/g1_cont_1991mean

**************************************************************************************************************************************
* Generate each component of the DID
**************************************************************************************************************************************
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

**************************************************************************************************************************************
* Get the ATT(1986,1988)
**************************************************************************************************************************************
gen att1986_1988 = (att_11-att_10) -(att_01 -att_00)
* ATT(1986,1988)=30.00279
* Drop variable so I can copy paste this code!
**************************************************************************************************************************************
drop ypost ypre g1_mean g1_cont_1991mean w1 w0 att_*



**************************************************************************************************************************************
** YOU GOT THE IDEA!
* Let me show now ATT(1986, 1992), which requires different comparison group (group 2 need to be excluded from the comparison group 
* bc they are treated in 1992).  Like before, I can use this pscore until year = 1997
**************************************************************************************************************************************
logit g1 if ((year==1997) & ((g1==1) | (time_til<0)))
predict pg1_1997


**************************************************************************************************************************************
* Calculate ATT(1986,1992)
* This the the ATT for the group first treated at 1986 (g1==1) in the first period since treatment (1992)
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1992
gen ypre = y if year==1985

**************************************************************************************************************************************
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant
**************************************************************************************************************************************
bysort year: egen g1_mean = mean(g1)

**************************************************************************************************************************************
* Pay attention to this formula, bc it changed!
**************************************************************************************************************************************
bysort year: egen g1_cont_1997mean = mean((1 - g1)*(1 - g2)*pg1_1997/(1 - pg1_1997))


**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = ((1 - g1)*(1 - g2)*pg1_1997/(1 - pg1_1997))/g1_cont_1997mean

**************************************************************************************************************************************
* Generate each component of the DID
**************************************************************************************************************************************
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

**************************************************************************************************************************************
* Get the ATT(1986,1992)
**************************************************************************************************************************************
gen att1986_1992 = (att_11-att_10) -(att_01 -att_00)
* ATT(1986,1992)= 69.9866
* Drop variable so I can copy paste this code!
**************************************************************************************************************************************
drop ypost ypre g1_mean g1_cont_1997mean w1 w0 att_*


**************************************************************************************************************************************
* Calculate ATT(1986,1993)
* This the the ATT for the group first treated at 1986 (g1==1) in the first period since treatment (1993)
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1993
gen ypre = y if year==1985

**************************************************************************************************************************************
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant
**************************************************************************************************************************************

bysort year: egen g1_mean = mean(g1)

**************************************************************************************************************************************
* Pay attention to this formula, bc it changed!
**************************************************************************************************************************************
bysort year: egen g1_cont_1997mean = mean((1 - g1)*(1 - g2)*pg1_1997/(1 - pg1_1997))


**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = ((1 - g1)*(1 - g2)*pg1_1997/(1 - pg1_1997))/g1_cont_1997mean

**************************************************************************************************************************************
* Generate each component of the DID
**************************************************************************************************************************************
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

**************************************************************************************************************************************
* Get the ATT(1986,1993)
**************************************************************************************************************************************
gen att1986_1993 = (att_11-att_10) -(att_01 -att_00)

* ATT(1986,1993)= 79.9764
* Drop variable so I can copy paste this code!
**************************************************************************************************************************************
drop ypost ypre g1_mean g1_cont_1997mean w1 w0 att_*

**************************************************************************************************************************************
* Let me show now ATT(1986, 1998), which requires different comparison group (group 3 now also need to be excluded from the comparison group bc they are treated in 1998)
* Like before, I can use this pscore until year = 2003
**************************************************************************************************************************************
logit g1 if ((year==2003) & ((g1==1) | (time_til<0)))
predict pg1_2003


**************************************************************************************************************************************
* Calculate ATT(1986,1998)
* This the the ATT for the group first treated at 1986 (g1==1) in year (1998)
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1998
gen ypre = y if year==1985

**************************************************************************************************************************************
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant
**************************************************************************************************************************************
bysort year: egen g1_mean = mean(g1)


**************************************************************************************************************************************
* Pay attention to this formula, bc it changed!
**************************************************************************************************************************************
bysort year: egen g1_cont_2003mean = mean(g4*pg1_2003/(1 - pg1_2003))


**************************************************************************************************************************************
* Get weights
**************************************************************************************************************************************
gen w1= g1/g1_mean
gen w0 = (g4*pg1_2003/(1 - pg1_2003))/g1_cont_2003mean

**************************************************************************************************************************************
* Generate each component of the DID
**************************************************************************************************************************************
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)

**************************************************************************************************************************************
* Get the ATT(1986,1998)
**************************************************************************************************************************************
gen att1986_1998 = (att_11-att_10) -(att_01 -att_00)
* ATT(1986,1998)= 129.96.82
* Drop variable so I can copy paste this code!
drop ypost ypre g1_mean g1_cont_2003mean w1 w0 att_*


***********************************************************************************************************************************************************
* Now let's do this for second group!
* Let me show now ATT(1992, 1992)
* Like before, I can use this pscore until year = 1997
logit g2 if ((year==1997) & ((g2==1) | (time_til<0)))
predict pg2_1997


**************************************************************************************************************************************
* Calculate ATT(1992,1992)
* This the the ATT for the secong first treated at 1992 (g2==1) in year 1992
*gen outcomes (easiest way to transform data into wide form is this)
**************************************************************************************************************************************
gen ypost = y if year==1992
gen ypre = y if year==1991

**************************************************************************************************************************************
* Generate Denominators of the weights
* We can use bysort here because g1 and and pg1_1991 are time-invariant
**************************************************************************************************************************************
bysort year: egen g2_mean = mean(g2)
* Pay attention to this formula, bc it changed!
bysort year: egen g2_cont_1997mean = mean((1-g1)*(1-g2)*pg2_1997/(1 - pg2_1997))
* Get weights
gen w1= g2/g2_mean
gen w0 = ((1-g1)*(1-g2)*pg2_1997/(1 - pg2_1997))/g2_cont_1997mean
* Generate each component of the DID
egen att_11 = mean(w1*ypost)
egen att_10 = mean(w1*ypre)
egen att_01 =  mean(w0*ypost)
egen att_00 = mean(w0*ypre)
* Get the ATT(1992,1992)
gen att1992_1992 = (att_11-att_10) -(att_01 -att_00)
* ATT(1992,1992)= 8
* Drop variable so I can copy paste this code!
drop ypost ypre g1_mean g1_cont_2003mean w1 w0 att_*

* I think now you know how to do the rest! =)


*********************************************************************************
* Aggregation over two ATTs(g,t)
* Combine att1986_1986 att1986_1987
* Formula is 2/T(T-1) Sum_g=2^T Sum_t=2^T 1(g<=t)ATT(g,t)
*	T is the number of g units (here 4)
*********************************************************************************
gen mean = 2/4*(4-1)
gen sum1 = att1986_1986 + att1986_1987
gen att= mean*sum1



*********************************************************************************
* This is Callaway & Sant'Anna via regressions
********************************************************************************
* Calculate ATT(1986,1986)
* This the the ATT for the group first treated at 1986 (g1==1) in the first period since treatment (1986)
reg y i.year g1 treat if ((year==1985 | year==1986) & ((g1==1) | (time_til<0)))
* ATT(1986,1986)=10.00096

* Now calculate ATT (1986, 1987)
reg y i.year g1 treat if ((year==1985 | year==1987) & ((g1==1) | (time_til<0)))
* ATT(1986, 1987) = 20.04393

* Now calculate ATT (1986, 1988)
reg y i.year g1 treat if ((year==1985 | year==1988) & ((g1==1) | (time_til<0)))
* ATT(1986, 1988) = 30.00874 

* Think now you got the idea!

* Let me illustrate how this works for second group, ATT(1992,1992)
reg y i.year g2 treat if ((year==1991 | year==1992) & ((g2==1) | (time_til<0)))
* ATT(1992,1992))=8.000199

*Now calculate  ATT(1992,1993))=8.000199
reg y i.year g2 treat if ((year==1991 | year==1993) & ((g2==1) | (time_til<0)))
*ATT(1992,1993))=16.01454

* For the third group, we ATT(1998,1998)
reg y i.year g3 treat if ((year==1997 | year==1998) & ((g3==1) | (time_til<0)))
*ATT(1998,1998) = 5.992923

* For the last group, we can't identify their ATT's because there is no valid comparison group!
