use https://github.com/scunning1975/mixtape/raw/master/abortion.dta, clear

* Second DDD model for 20-24 year olds vs 25-29 year olds black females in repeal vs Roe states
gen younger2 = 0 
replace younger2 = 1 if age == 20
gen yr2=(repeal==1) & (younger2==1)
gen wm=(wht==1) & (male==1)
gen wf=(wht==1) & (male==0)
gen bm=(wht==0) & (male==1)
gen bf=(wht==0) & (male==0)
char year[omit] 1985 
char repeal[omit] 0 
char younger2[omit] 0 
char fip[omit] 1 
char fa[omit] 0 
char yr2[omit] 0  
xi: reg lnr i.repeal*i.year i.younger2*i.repeal i.younger2*i.year i.yr2*i.year i.fip*t acc pi ir alcohol crack  poverty income ur if bf==1 & (age==20 | age==25) [aweight=totpop], cluster(fip) 
