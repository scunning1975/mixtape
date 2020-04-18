clear all 
set obs 10000 

* Half of the population is female. 
generate female = runiform()>=0.5 

* Innate ability is independent of gender. 
generate ability = rnormal() 

* All women experience discrimination. 
generate discrimination = female 

* Data generating processes
generate occupation = (1) + (2)*ability + (0)*female + (-2)*discrimination + rnormal() 
generate wage = (1) + (-1)*discrimination + (1)*occupation + 2*ability + rnormal() 

* Regressions
regress wage female 
regress wage female occupation 
regress wage female occupation ability


