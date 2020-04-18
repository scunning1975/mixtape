ssc install reganat, replace
sysuse auto.dta, replace
regress price length
regress price length weight headroom mpg
reganat price length weight headroom mpg, dis(length) biline
