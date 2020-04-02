library(readstata13)

setwd("/Users/hsantanna/Desktop")


####Example 1 - Page 82####
yule = read.dta13("yule.dta")

attach(yule)


  reg.yule = lm(paup ~ outrelief + old + pop)
  summary(reg.yule)
  
  
####Example 2 - Page 93####
  
gap = function() 
{
  df = data.frame(y1 = c(7,5,5,7,4,10,1,5,3,9),
                  y0 = c(1,6,1,8,2,1,10,6,7,8),
                  random = rnorm(10))
  
  df = df[order(df$random),]
  
  d = c(rep(1,5), rep(0,5))
  
  df$y = d * df$y1 + (1-d) * df$y0
  
  sy1 = mean(df$y[1:5])
  sy0 = mean(df$y[6:10])
  
  sdo = sy1 - sy0
  
  return(sdo)
}

sim = replicate(10000, gap())
mean(sim)


####Example 3 - Page 96-...###

star_sw <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/star_sw.dta")

#%#%#%#

star_reg <- lm(tscorek ~ sck + rak, data = star_sw)

summary(star_reg)


