clear all 
program define ols, rclass 
version 14.2 
syntax [, obs(integer 1) mu(real 0) sigma(real 1) ] 

	clear 
	drop _all 
	set obs 10000 
	gen x = 9*rnormal()  
	gen u  = 36*rnormal()  
	gen y  = 3 + 2*x + u 
	reg y x 
	end 

simulate beta=_b[x], reps(1000): ols 
su 
hist beta
