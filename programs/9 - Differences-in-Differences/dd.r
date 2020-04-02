WORK.DIR = "~/Documents/Mestrado/Remix/"
setwd(WORK.DIR)

options(max.print=100000)

#Load all packages of the R universe
packages <- c("readstata13", "sandwich","stargazer","plm","clipr","ri2", 
              "Synth","kernlab", "vtable","Hmisc", "lmtest","devtools", "estimatr")
not_installed <- !packages %in% installed.packages()
if(any(not_installed)) install.packages(packages[not_installed])
lapply(packages, require, character.only=TRUE)

#Load Data
abortion = read.dta13("abortion.dta", convert.factors = FALSE)
abortion = na.omit(abortion)

#Dif-Dif
abortion$repeal <- factor(abortion$repeal)
abortion$year <- factor(abortion$year)
abortion$fip <- factor(abortion$fip)
abortion$fa <- factor(abortion$fa)

abortion$did = repeal*year

levels(abortion$fip)

reg.did = lm_robust(lnr ~ repeal*year + fip + acc+ ir + pi + alcohol+ crack + poverty+ income+ ur,
             data=subset(abortion, bf15 == 1), weights = totpop, clusters = fip)

stargazer(reg.did,coeftest(reg.did,
                           vcov=vcovHC(reg.did,type="HC0",cluster="group")),type = "text")
summary(reg.did)

#DDD
abortion$yr <- factor(ifelse(abortion$repeal == 1 & abortion$younger == 1, 1, 0))
abortion$wm <- factor(ifelse(abortion$wht==1 & abortion$male==1, 1, 0))
abortion$wf <- factor(ifelse(abortion$wht==1 & abortion$male==0, 1, 0))
abortion$bm <- factor(ifelse(abortion$wht==0 & abortion$male==1, 1, 0))
abortion$bf <- factor(ifelse(abortion$wht==0 & abortion$male==0, 1, 0))

abortion$younger <- factor(abortion$younger)


df <- subset(abortion, bf == 1 & 
               (age == 15 | age == 25))

regddd_a <-  lm_robust(lnr ~ repeal*year + younger*repeal + younger*year + yr*year + fip*t + acc + ir + pi + alcohol + crack + poverty + income + ur,
                    data = df, weights = totpop, clusters = fip)

regddd_b <- lm_robust(lnr ~ repeal*year + younger*repeal + younger*year + yr*year + fip*t + younger*t + fa*t + acc + pi + ir + alcohol + crack + poverty + income + ur,
                      data = df, weights = totpop, clusters = fip)

summary(regddd_a)
summary(regddd_b)
