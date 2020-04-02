* Nonparametric estimation graphic
ssc install cmogram
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) qfitci
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) lfit
cmogram score lagdemvoteshare, cut(0.5) scatter line(0.5) lowess
