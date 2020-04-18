* Note kernel-weighted local polynomial regression is a smoothing method.
capture drop sdem* x1 x0
lpoly score demvoteshare if democrat == 0, nograph kernel(triangle) gen(x0 sdem0) bwidth(0.1)}
lpoly score demvoteshare if democrat == 1, nograph kernel(triangle) gen(x1 sdem1)  bwidth(0.1)}
scatter sdem1 x1, color(red) msize(small) || scatter sdem0 x0, msize(small) color(red) xline(0.5,lstyle(dot)) legend(off) xtitle("Democratic vote share") ytitle("ADA score")

