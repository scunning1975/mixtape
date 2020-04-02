# Terry Tsai
# Panel Data
# August 2019

#Set Directory
WORK.DIR = "~/Dropbox/Mixtape/Book/R Codes/9 - Panel Data"
setwd(WORK.DIR)


#Install package

########################### CHANGE - to just LIBRARY
packages <- c( "MESS","clipr","stargazer","readstata13","AER","devtools",
               "systemfit","plm","sandwich","Jmisc")
not_installed <- !packages %in% installed.packages()
if(any(not_installed)) install.packages(packages[not_installed])
lapply(packages, require, character.only=TRUE)
###########################

#Load Data
sasp = read.dta13("./sasp_panel.dta", convert.factors = FALSE)

#P. 250 Fixed Effect Canonical Form 
model.plm = plm(Y ~ D, data = data, index = c("state","year"), method = "within", effect = "twoways")

#P.251 Clustered standard error
coeftest(model.plm, vcov=vcovHC(model.plm,type="HC0",cluster="group"))

#******P.258*******#
#Delete all NA
sasp = na.omit(sasp)
#Order by id and session 
attach(sasp)
sasp = sasp[order(id,session),]
#Balance Data
sasp.b = make.pbalanced(sasp, balance.type = "shared.individuals")
#Demean Data
attach(sasp.b)
sasp.b = transform(sasp.b, 
          demean_lnw = lnw - ave(lnw, id),
          demean_age = age - ave(age, id),
          demean_asq = asq - ave(asq, id),
          demean_bmi = bmi - ave(bmi, id),
          demean_hispanic = hispanic - ave(hispanic, id),
          demean_black = black - ave(black, id),
          demean_other = other - ave(other, id),
          demean_asian = asian - ave(asian, id),
          demean_schooling = schooling - ave(schooling, id),
          demean_cohab = cohab - ave(cohab, id),
          demean_married = married - ave(married, id),
          demean_divorced = divorced - ave(divorced, id),
          demean_separated = separated - ave(separated, id),
          demean_age_cl = age_cl - ave(age_cl, id),
          demean_unsafe = unsafe - ave(unsafe, id),
          demean_llength = llength - ave(llength, id),
          demean_reg = reg - ave(reg, id),
          demean_asq_cl = asq_cl - ave(asq_cl, id),
          demean_appearance_cl = appearance_cl - ave(appearance_cl, id),
          demean_provider_second = provider_second - ave(provider_second, id),
          demean_asian_cl = asian_cl - ave(asian_cl, id),
          demean_black_cl = black_cl - ave(black_cl, id),
          demean_hispanic_cl = hispanic_cl - ave(hispanic_cl, id),
          demean_othrace_cl = othrace_cl - ave(lnw, id),
          demean_hot = hot - ave(hot, id),
          demean_massage_cl = massage_cl - ave(massage_cl, id)
)

#POLS
ols = lm(lnw ~ age+ asq+ bmi+ hispanic+ black+ other+ asian+ schooling+ cohab+ married+ divorced+ separated+ 
           age_cl+ unsafe+ llength+ reg+ asq_cl+ appearance_cl+ provider_second+ asian_cl+ black_cl+ hispanic_cl+ 
           othrace_cl+ hot+ massage_cl)
summary(ols)

coeftest(ols, vcov=vcovHC(ols,type="HC0",cluster="group"))


#FE
model.plm = plm(lnw ~ age+ asq+ bmi+ hispanic+ black+ other+ asian+ schooling+ cohab+ married+ divorced+ separated+ 
                  age_cl+ unsafe+ llength+ reg+ asq_cl+ appearance_cl+ provider_second+ asian_cl+ black_cl+ hispanic_cl+ 
                  othrace_cl+ hot+ massage_cl,
                  data = sasp.b, index = c("id","session"), method = "within", effect = "twoways")
summary(model.plm)
coeftest(model.plm, vcov=vcovHC(model.plm,type="HC0",cluster="group"))

#Demean OLS
ols.demean = lm(demean_lnw ~ demean_age+ demean_asq+ demean_bmi+ demean_hispanic+ demean_black+ demean_other+
                demean_asian+ demean_schooling+ demean_cohab+ demean_married+ demean_divorced+ demean_separated+
                demean_age_cl+ demean_unsafe+ demean_llength+ demean_reg+ demean_asq_cl+ demean_appearance_cl+ 
                demean_provider_second+ demean_asian_cl+ demean_black_cl+ demean_hispanic_cl+ demean_othrace_cl+
                demean_hot+ demean_massage_cl, data = sasp.b)
summary(ols.demean)
coeftest(ols.demean, vcov=vcovHC(ols.demean,type="HC0",cluster="group"))


