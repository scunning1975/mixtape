WORK.DIR = "/Users/Terry/Documents/Baylor Economics/Remix/DD/Data"
setwd(WORK.DIR)

#Load all packages of the R universe
packages <- c("readstata13", "sandwich","stargazer","plm","clipr","ri2", 
              "Synth","kernlab", "vtable","Hmisc", "lmtest","devtools")
not_installed <- !packages %in% installed.packages()
if(any(not_installed)) install.packages(packages[not_installed])
lapply(packages, require, character.only=TRUE)

#Load Data
abortion = read.dta13("abortion.dta", convert.factors = FALSE)
abortion = na.omit(abortion)
#Dif-Dif
attach(abortion)
abortion$did = repeal*year
reg.did = lm(lnr ~ did + fip + acc+ ir + pi + alcohol+ crack + poverty+ income+ ur,
             data=subset(abortion, bf15 == 1 & year == 1986), weights = totpop)
stargazer(reg.did,coeftest(reg.did,
                           vcov=vcovHC(reg.did,type="HC0",cluster="group")),type = "text")
summary(reg.did)
