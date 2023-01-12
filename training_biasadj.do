* Nearest neighbor matching using teffects with bias correction. Dataset is the matched sample from using the minimizing of the non-normalized Euclidean distance from earlier
clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/training_biasadj.dta, clear

* First estimate a regression model of earnings onto gpa and age using only the control group
reg earnings gpa age if treat==0, nocons

* Second predict mu(0) for D=1 and D=0 using the predict command
predict mu

* reshape the data
reshape wide unit age gpa earnings mu, i(matched) j(treat)
gen age= age1-age0
gen gpa = gpa1-gpa0
gen att = (earnings1 - earnings0)
gen atti = (earnings1 - earnings0) - (mu1-mu0)
collapse (mean) atti att age gpa
list
