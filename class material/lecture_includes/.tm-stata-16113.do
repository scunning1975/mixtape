use nsw_psid.dta, replace
qui probit treated age black hispanic married educ nodegree re75
margins, dydx(_all)
predict double score
density2 score, group(treated) saving(psm2a, replace)
graph export psm2a.pdf, replace
psgraph, treated(treated) pscore(score) bin(50) saving(psm2b, replace)
graph export psm2b.pdf, replace
