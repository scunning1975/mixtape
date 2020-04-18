use https://github.com/scunning1975/mixtape/raw/master/training_example.dta, clear
histogram age_treat, bin(10) frequency
histogram age_control, bin(10) frequency
su age_treat age_control
su earnings_treat earnings_control

histogram age_treat, bin(10) frequency
histogram age_matched, bin(10) frequency
su age_treat age_control
su earnings_matched earnings_matched
