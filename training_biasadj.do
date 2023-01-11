* Nearest neighbor matching using teffects with bias correction
clear
capture log close
use https://github.com/scunning1975/mixtape/raw/master/training_biasadj.dta, clear


* Nearest neighbor match on age and high school gpa for the ATET using euclidean distance with bias adjustment
teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(eucl) generate(naynum1) biasadj(age gpa)

* Nearest neighbor match on age and high school gpa for the ATET using variance along diagonal of covariance matrix with bias adjustment
teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(ivar) generate(naynum2) biasadj(age gpa)

* Nearest neighbor match on age and high school gpa for the ATET using Mahalanobis distance with bias adjustment
teffects nnmatch (earnings age gpa) (treat), atet nn(1) metric(maha) generate(naynum3) biasadj(age gpa) 

list treat unit naynum* in 1/10

