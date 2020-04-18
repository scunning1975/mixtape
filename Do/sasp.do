use https://github.com/scunning1975/mixtape/raw/master/sasp_panel.dta, clear
tsset id session
foreach x of varlist lnw age asq bmi hispanic black other asian schooling cohab married divorced separated age_cl unsafe llength reg asq_cl appearance_cl provider_second asian_cl black_cl hispanic_cl othrace_cl hot massage_cl 
drop if `x'==.
bysort id: gen s=_N
keep if s==4
foreach x of varlist lnw age asq bmi hispanic black other asian schooling cohab married divorced separated age_cl unsafe llength reg asq_cl appearance_cl provider_second asian_cl black_cl hispanic_cl  othrace_cl hot massage_cl 

egen mean_`x'=mean(`x'), by(id)
gen demean_`x'=`x' - mean_`x'
drop mean*

xi: reg lnw  age asq bmi hispanic black other asian schooling cohab married divorced separated age_cl unsafe llength reg asq_cl appearance_cl provider_second asian_cl black_cl hispanic_cl othrace_cl hot massage_cl, robust
xi: xtreg lnw  age asq bmi hispanic black other asian schooling cohab married divorced separated age_cl unsafe llength reg asq_cl appearance_cl provider_second asian_cl black_cl hispanic_cl othrace_cl hot massage_cl, fe i(id) robust
reg demean_lnw demean_age demean_asq demean_bmi demean_hispanic demean_black demean_other demean_asian demean_schooling demean_cohab demean_married demean_divorced demean_separated demean_age_cl demean_unsafe demean_llength demean_reg demean_asq_cl demean_appearance_cl demean_provider_second demean_asian_cl demean_black_cl demean_hispanic_cl demean_othrace_cl demean_hot demean_massage_cl, robust cluster(id)
