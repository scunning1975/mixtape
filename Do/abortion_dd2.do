use https://github.com/scunning1975/mixtape/raw/master/abortion.dta, clear

* Second DD model for 20-24 year old black females
char year[omit] 1985 
xi: reg lnr i.repeal*i.year i.fip acc ir pi alcohol crack poverty income ur if (race==2 & sex==2 & age==20) [aweight=totpop], cluster(fip) 
