####Example 1 - Page 115####
library(readstata13)
titanic = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/titanic.dta")
titanic$class = ifelse(titanic$class == "1st class",1,0)
titanic$age = ifelse(titanic$age == "child", 0,1)
titanic$sex = ifelse(titanic$sex == "man", 1,0)
titanic$survived = ifelse(titanic$survived == "yes", 1, 0)
attach(titanic)

ey1 = mean(survived[which(class == 1)])
ey0 = mean(survived[which(class != 1)])
sdo = ey1 - ey0


####Example 2 - Page 117####
ey11 = mean(survived[which(age == 1 & sex == 0  & class == 1)])
ey10 = mean(survived[which(age == 1 & sex == 0  & class != 1)])
ey21 = mean(survived[which(age == 0 & sex == 0  & class == 1)])
ey20 = mean(survived[which(age == 0 & sex == 0  & class != 1)])
ey31 = mean(survived[which(age == 1 & sex == 1  & class == 1)])
ey30 = mean(survived[which(age == 1 & sex == 1  & class != 1)])
ey41 = mean(survived[which(age == 0 & sex == 1  & class == 1)])
ey40 = mean(survived[which(age == 0 & sex == 1  & class != 1)])

diff1 = ey11 - ey10
diff2 = ey21 - ey20
diff3 = ey31 - ey30
diff4 = ey41 - ey40

obs = nrow(titanic)

wt1 = length(which(age == 1 & sex == 0  & class != 1))/obs
wt2 = length(which(age == 0 & sex == 0  & class != 1))/obs
wt3 = length(which(age == 1 & sex == 1  & class != 1))/obs
wt4 = length(which(age == 0 & sex == 1  & class != 1))/obs
wate = diff1*wt1 + diff2*wt2 + diff3*wt3 + diff4*wt4

library(stargazer)
stargazer(wate, sdo, type = "text")
detach(titanic)


####Example 3 - Page 122 & 125####

library(readstata13)
training_example = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/training_example.dta")

library(tidyverse)
ggplot(training_example, aes(x=age_treat)) +
  geom_histogram(bins = 5, na.rm = TRUE) +
  geom_vline(aes(xintercept = mean(na.omit(age_treat))),
             color = "blue", linetype = "dashed", size = 1)
  
ggplot(training_example, aes(x=age_control)) +
  geom_histogram(bins = 5, na.rm = TRUE) +
  geom_vline(aes(xintercept = mean(na.omit(age_control))),
             color = "blue", linetype = "dashed", size = 1)

ggplot(training_example, aes(x=age_matched)) +
  geom_histogram(bins = 5, na.rm = TRUE) +
  geom_vline(aes(xintercept = mean(na.omit(age_matched))),
             color = "blue", linetype = "dashed", size = 1)

library(stargazer)
stargazer(training_example, type = "text")


####Example 4 - Page 131####

library(readstata13)

library(tidyverse)
training_bias_reduction = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/training_bias_reduction.dta")

train.reg = lm(Y ~ X, training_bias_reduction)
predict(train.reg)

####Example 5 - Page 140#### HAS ISSUES

library(readstata13)
nsw_dw <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/nsw_dw.dta")

summary(nsw_dw$re78[nsw_dw$treat == 1])
nsw_dw$y1 <- mean(nsw_dw$re78[nsw_dw$treat == 1])

summary(nsw_dw$re78[nsw_dw$treat == 0])
nsw_dw$y0 <- mean(nsw_dw$re78[nsw_dw$treat == 0])

nsw_dw$ate = nsw_dw$y1 - nsw_dw$y0

unique(nsw_dw$ate)
6349.144 - 4554.801

#Append part
nsw_dw_cpscontrol <- read.dta13("http://scunning.com/teaching/cps_controls.dta")
nsw_dw <- merge(nsw_dw, nsw_dw_cpscontrol, all = TRUE)

nsw_dw$agesq <- nsw_dw$age*nsw_dw$age
nsw_dw$agecube <- nsw_dw$age^3

nsw_dw$school <- nsw_dw$education
nsw_dw$education <- NULL

nsw_dw$schoolsq <- nsw_dw$school^2 

nsw_dw$u74 <- ifelse(nsw_dw$re74==0, 1, 0)
nsw_dw$u75 <- ifelse(nsw_dw$re75==0, 1, 0)

nsw_dw$interaction1 <- nsw_dw$school*nsw_dw$re74

nsw_dw$re74sq <- nsw_dw$re74^2
nsw_dw$re75sq <- nsw_dw$re75^2

nsw_dw$interaction1 <- nsw_dw$u74*nsw_dw$hispanic

logit_nsw <- glm(treat ~ age + agesq + agecube + school + schoolsq +
                 married + nodegree + black + hispanic + re74 + re75 + u74 +
                   u75 + interaction1, family = binomial(link = "logit"), data = nsw_dw)

summary(logit_nsw)

pscore <- predict(logit_nsw)











