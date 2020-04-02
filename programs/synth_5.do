** Inference 2: Estimate the pre- and post-RMSPE and calculate the ratio of the
*  post-pre RMSPE	
set more off
local statelist  1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 20 21 22 23 24 25 26 27 28 29 30 31 32 
	33 34 35 36 37 38 39 40 41 42 45 46 47 48 49 51 53 55
foreach i of local statelist {

	use ../data/synth/synth_gap_bmprate`i', clear
	gen gap3=gap`i'*gap`i'
	egen postmean=mean(gap3) if year>1993
	egen premean=mean(gap3) if year<=1993
	gen rmspe=sqrt(premean) if year<=1993
	replace rmspe=sqrt(postmean) if year>1993
	gen ratio=rmspe/rmspe[_n-1] if 1994
	gen rmspe_post=sqrt(postmean) if year>1993
	gen rmspe_pre=rmspe[_n-1] if 1994
	mkmat rmspe_pre rmspe_post ratio if 1994, matrix (state`i')
