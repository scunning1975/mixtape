clear all 
set seed 3444 

* 2500 independent draws from standard normal distribution 
set obs 2500 
generate beauty=rnormal() 
generate talent=rnormal() 

* Creating the collider variable (star) 
gen score=(beauty+talent) 
egen c85=pctile(score), p(85)   
gen star=(score>=c85) 
label variable star "Movie star" 

* Conditioning on the top 15\% 
twoway (scatter beauty talent, mcolor(black) msize(small) msymbol(smx)), ytitle(Beauty) xtitle(Talent) subtitle(Aspiring actors and actresses) by(star, total)