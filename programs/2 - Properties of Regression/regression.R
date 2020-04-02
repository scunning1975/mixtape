####Example 1 - Page 45
library(tidyverse)
set.seed(1)
x = rnorm(10000)
u = rnorm(10000)
y = 5.5*x + 12*u

lm.y <- lm(y ~ x)
yhat1 <- predict(lm.y)
yhat2 <- lm.y$coef[1] + lm.y$coef[2]*x
summary(yhat1)
summary(yhat2)

uhat1 <- resid(lm.y)
uhat2 = y - yhat2
summary(uhat1)
summary(uhat2)

plot(x, y, main = "OLS Regression Line")
abline(reg = lm.y)

#Plotting

ggplot(lm.y, aes(x=x, y=y)) + 
  ggtitle("OLS Regression Line") +
  geom_point(size = 0.3, color = "black") +
  geom_smooth(method = lm, color = "black") +
  annotate("text", x = -1.5, y = 30, color = "red", 
           label = paste("Intercept =",signif(lm.y$coef[1]))) +
  annotate("text", x = 1.5, y = -30, color = "blue", 
           label = paste("Slope =",signif(lm.y$coef[2])))
  


####Example 2 - Page 47
library(stargazer)

set.seed(1234)

x = 9*rnorm(10)
u = 36*rnorm(10)
y = 3 + 2*x + u

lm.y = lm(y ~ x)
yhat = predict(lm.y)
uhat = lm.y$residuals

sum = data.frame(x,u,y,yhat,uhat,x*uhat,yhat*uhat)
stargazer(sum, type = "text")


####Example 3 - Page 53
library(tidyverse)

set.seed(NULL)
beta = NULL
for(i in 1:1000)
{
  x = 9*rnorm(10000)
  u = 36*rnorm(10000)
  y = 3 + 2*x + u
  lm.y = lm(y ~ x)
  beta[i] = lm.y$coef[2]
}

sd(beta)
mean(beta)

beta = data.frame(beta)
ggplot(beta, aes(x=beta)) + geom_histogram(color="black", fill="grey", bins = 30)


####Example 4 - Page 61
library(readstata13)

attach(read.dta13("http://www.stata-press.com/data/r9/auto.dta"))
length = length-mean(length)

lm.auto_bivar = lm(price ~ length)

lm.autoaux = lm(length ~ weight + headroom + mpg)

resid_length = lm.autoaux$residuals
beta_multi = cov(price, resid_length)/var(resid_length)
intercept = lm.auto_bivar$coefficients[1]

y_multi = intercept + beta_multi * length

ggplot(lm.auto_bivar, aes(x=length, y=price)) + 
  ggtitle("Reganat") +
  geom_point(size = 1, color = "black") +
  geom_smooth(method = lm, color = "blue", se = FALSE) +
  geom_line(aes(x=length,y=y_multi),color='red')













