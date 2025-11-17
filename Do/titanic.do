use https://github.com/scunning1975/mixtape/raw/master/titanic.dta, clear
gen female=(sex==0)
label variable female "Female"
gen male=(sex==1)
label variable male "Male"
gen 	s=1 if (female==1 & age==1)
replace s=2 if (female==1 & age==0)
replace s=3 if (female==0 & age==1)
replace s=4 if (female==0 & age==0)
gen 	d=1 if class==1
replace d=0 if class!=1
summarize survived if d==1
gen ey1=r(mean)
summarize survived if d==0
gen ey0=r(mean)
gen sdo=ey1-ey0
su sdo