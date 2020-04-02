setwd("/Users/hsantanna/Desktop")

library(readstata13)

abortion = read.dta13("abortion.dta")

write.csv(abortion, "abortion.csv")

library(multiwayvcov)

####Example 1 - Page 75####

female = ifelse(runif(10000)>=0.5,1,0)
ability = rnorm(10000)
discrimination = female
occupation = 1 + 2*ability + 0*female - 2*discrimination + rnorm(10000)
wage = 1 - 1*discrimination + 1*occupation + 2*ability + rnorm(10000)

lm.1 = lm(wage ~ female)
lm.2 = lm(wage ~ female + occupation)
lm.3 = lm(wage ~ female + occupation + ability)

library(stargazer)
stargazer(lm.1,lm.2,lm.3, type = "text", column.labels = c("Biased Unconditional", "Biased",
                                                           "Unbiased Unconditional"))

####Example 2 - Page 76####
set.seed(541)

z = rnorm(2500)
k = rnorm(2500, 10,4)
d = ifelse(k>=12,1,0)

y = d*50 + 100 + rnorm(2500)
x = d*50 + y + rnorm(2500,50,1)

library(MASS) #For robust regression

rlm.1 = rlm(y ~ d)
rlm.2 = rlm(y ~ x)
rlm.3 = rlm(y ~ x + d)

stargazer(rlm.1,rlm.2,rlm.3, type = "text")


####Example 3 - Page 77####
set.seed(3444)

beauty = rnorm(2500)
talent = rnorm(2500)

score = beauty + talent
c85 = quantile(score, .85)
star = ifelse(score>=c85,1,0)

moviestar = data.frame(beauty, talent, star)
is.star = subset(moviestar, star == 1)
not.star = subset(moviestar, star == 0)

lm.1 = lm(beauty ~ talent, data = moviestar)
lm.2 = lm(beauty ~ talent, data = is.star)
lm.3 = lm(beauty ~ talent, data = not.star)

library(tidyverse)
library(gridExtra)
plot1 = ggplot(lm.1, aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

plot2 = ggplot(lm.2, aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

plot3 = ggplot(lm.3, aes(x = talent, y = beauty)) +
  geom_point(size = 0.5, shape=23) + xlim(-4, 4) + ylim(-4, 4)

grid.arrange(plot1, plot2, plot3, ncol=2)

