ebalance treat age agesq agecube school schoolsq 
  married nodegree black hispanic re74 re75 
  u74 u75  interaction1 if id!=3, targets(1) 

svyset [pweight=_webal] 

svy: reg re78 treat if id!=3

twoway (kdensity age if treat==1 & id!=3, bw(3)) 
  (kdensity age [aweight=_webal] if treat==0, 
  bw(3)), xtitle("age") legend(label(1 "treated") 
  label(2 "control")) title("Balancing on the
  1st order")
