clear
input  d y
0 	 0.22         
0 	-0.87        
0 	-2.39        
0 	-1.79        
0 	 0.37         
0 	-1.54        
0 	 1.28         
0 	-0.31        
0 	-0.74        
0 	 1.72         
0 	 0.38         
0 	-0.17        
0 	-0.62        
0 	-1.10        
0 	 0.30         
0 	 0.15         
0 	 2.30         
0 	 0.19         
0 	-0.50        
0 	-0.09        
1 	-5.13 
1 	-2.19 
1 	-2.43 
1 	-3.83 
1 	 0.50 
1 	-3.25 
1 	 4.32 
1 	 1.63 
1 	 5.18 
1 	-0.43 
1 	 7.11 
1 	 4.87 
1 	-3.10 
1 	-5.81 
1 	 3.76 
1 	 6.31 
1 	 2.58 
1 	 0.07 
1 	 5.76 
1 	 3.50
end

twoway (kdensity y if d==1) (kdensity y if d==0, lcolor(blue) lwidth(medium) lpattern(dash)), \\\
title(Kolmogorov-Smirnov test) legend(order(1 ``Treatment'' 2 ``Control''))