* Manual with non-normalized weights using all the data
gen d1=treat/pscore
gen d0=(1-treat)/(1-pscore)
egen s1=sum(d1)
egen s0=sum(d0)

gen y1=treat*re78/pscore
gen y0=(1-treat)*re78/(1-pscore)
gen ht=y1-y0

* Manual with normalized weights
replace y1=(treat*re78/pscore)/(s1/_N)
replace y0=((1-treat)*re78/(1-pscore))/(s0/_N)
gen norm=y1-y0
su ht norm

* ATT under non-normalized weights is -$11,876
* ATT under normalized weights is -$7,238

drop d1 d0 s1 s0 y1 y0 ht norm

* Trimming the propensity score
drop if pscore <= 0.1 
drop if pscore >= 0.9

* Manual with non-normalized weights using trimmed data
gen d1=treat/pscore
gen d0=(1-treat)/(1-pscore)
egen s1=sum(d1)
egen s0=sum(d0)

gen y1=treat*re78/pscore
gen y0=(1-treat)*re78/(1-pscore)
gen ht=y1-y0

* Manual with normalized weights using trimmed data
replace y1=(treat*re78/pscore)/(s1/_N)
replace y0=((1-treat)*re78/(1-pscore))/(s0/_N)
gen norm=y1-y0
su ht norm

* ATT under non-normalized weights is $2,006
* ATT under normalized weights is $1,806
