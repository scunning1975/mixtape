use https://github.com/scunning1975/mixtape/raw/master/ri.dta, clear

tempfile ri
gen id = _n
save "`ri'", replace

* Create combinations
* ssc install percom
combin id, k(4)
gen permutation = _n
tempfile combo
save "`combo'", replace

forvalue i =1/4 {
	ren id_`i' treated`i'
}


destring treated*, replace
cross using `ri'
sort permutation name
replace d = 1 if id == treated1 | id == treated2 | id == treated3 | id == treated4
replace d = 0 if ~(id == treated1 | id == treated2 | id == treated3 | id == treated4)

* Calculate true effect using absolute value of SDO
egen 	te1 = mean(y) if d==1, by(permutation)
egen 	te0 = mean(y) if d==0, by(permutation)

collapse (mean) te1 te0, by(permutation)
gen 	ate = te1 - te0
keep 	ate permutation

sort ate
gen rank = _n
su rank if permutation==1
gen pvalue = (`r(mean)'/70)
list pvalue if permutation==1
* pvalue equals 0.6
