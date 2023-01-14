* Matching with and without bias adjustment
capture log close
clear
use https://github.com/scunning1975/mixtape/raw/master/training_biasadj.dta, clear

* Recall the ATT was estimated to be $1607.50
su earnings if treat==1
local y1 = `r(mean)'
gen y1=`y1'
su y1

su earnings if treat==0
local y2 = `r(mean)'
gen y2=`y2'
su y2

gen att = y1-y2
su att // ATT $1607.50

* Estimate earnings using OLS on age and gpa but only control group
reg earnings gpa if treat==0 ,nocons
predict mu

reshape wide age gpa earning unit mu, i(matched) j(treat)

gen diff = (earnings1 - earnings0)
su diff // $1607.50

gen diff_biasadj = (earnings1 - earnings0) - (mu1 - mu0)
su diff_biasadj

