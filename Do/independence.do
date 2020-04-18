clear all
program define gap, rclass

	version 14.2
	syntax [, obs(integer 1) mu(real 0) sigma(real 1) ]
	clear
	drop _all
	set obs 10
	gen 	y1 = 7 in 1
	replace y1 = 5 in 2
	replace y1 = 5 in 3
	replace y1 = 7 in 4
	replace y1 = 4 in 5
	replace y1 = 10 in 6
	replace y1 = 1 in 7
	replace y1 = 5 in 8
	replace y1 = 3 in 9
	replace y1 = 9 in 10

	gen 	y0 = 1 in 1
	replace y0 = 6 in 2
	replace y0 = 1 in 3
	replace y0 = 8 in 4
	replace y0 = 2 in 5
	replace y0 = 1 in 6
	replace y0 = 10 in 7
	replace y0 = 6 in 8
	replace y0 = 7 in 9
	replace y0 = 8 in 10
	drawnorm random
	sort random

	gen 	d=1 in 1/5
	replace d=0 in 6/10
	gen 	y=d*y1 + (1-d)*y0
	egen sy1 = mean(y) if d==1
	egen sy0 = mean(y) if d==0			
	collapse (mean) sy1 sy0
	gen sdo = sy1 - sy0
	keep sdo
	summarize sdo
	gen mean = r(mean)
	end

simulate mean, reps(10000): gap
su _sim_1 

