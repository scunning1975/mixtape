clear
capture log close

* Create the data. 4 cups with tea, 4 cups with milk.

set obs 8
gen cup = _n

* Assume she guesses the first cup (1), then the second cup (2), and so forth
gen 	guess = 1 in 1
replace guess = 2 in 2
replace guess = 3 in 3
replace guess = 4 in 4
replace guess = 0 in 5
replace guess = 0 in 6
replace guess = 0 in 7
replace guess = 0 in 8
label variable guess "1: she guesses tea before milk then stops"

tempfile correct
save "`correct'", replace

* ssc install percom
combin cup, k(4)
gen permutation = _n
tempfile combo
save "`combo'", replace

destring cup*, replace
cross using `correct'
sort permutation cup

gen 	correct = 0
replace correct = 1 if cup_1 == 1 & cup_2 == 2 & cup_3 == 3 & cup_4 == 4

* Calculation p-value
count if correct==1
local correct `r(N)'
count
local total `r(N)'
di `correct'/`total'
gen pvalue = (`correct')/(`total')
su pvalue

* pvalue equals 0.014
 
capture log close
exit
