# library(devtools)
# devtools::install_github('johnson-shuffle/mixtape')
# library(mixtape)
# 
# 
# devtools::install_github("bcastanho/sctools")
# library(SCtools)




###Page 364#%#%#%#%#
library(readstata13)
library(MSCMT)
library(dplyr)
library(gsynth)



texas <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/texas.dta")

#%#%#%#%#% TEMPORARY#%#%#%#%#
setwd("~/Documents/Mestrado/Remix")
state_ansi_fips <- read.csv("./us-state-ansi-fips.csv")
colnames(state_ansi_fips) <- c("state_name", "statefip", "acron")
state_ansi_fips$statefip <- as.numeric(state_ansi_fips$statefip) 
texas <- merge(texas, state_ansi_fips)
texas$state_name <- as.character(texas$state_name)
#%#%#%#%#%#%#%#%#%%##%%#%#%##

temp <- texas[c(20,21,22)]
sum(is.na(temp))
sum(is.na(texas))

texas <- texas[c(-20,-21,-22)]

for (i in 1:length(texas))
{
  print(sum(is.na(texas[i])))
}


texas$D <- ifelse(texas$state_name == "Texas" & texas$year == 1993, 1,0)


system.time(
out <- gsynth(bmprison ~ D + bmprison + alcohol + aidscapita + income + ur + poverty + black + perc1519, data = texas, index = c("statefip","year"), force = "unit", CV = TRUE, r = c(0, 5), se = TRUE, inference = "parametric", nboots = 1000, parallel = TRUE)
)
plot(out)
plot(out, type = "counterfactual", raw = "none", main="")
out$wgt.implied

weight <- data.frame(rownames(out$wgt.implied), out$wgt.implied)
colnames(weight) <- c("state", "weight")
rownames(weight) <- NULL



varname <- c("state_name","statefip", "year", "bmprison", "alcohol", 
                 "aidscapita", "poverty", "ur", "black", "income", "perc1519")

texas <- texas %>%
  select(varname)


texas <- listFromLong(texas, unit.variable="statefip", 
                      time.variable="year", unit.names.variable = "state_name")



treatment.identifier <- "Texas"
controls.identifier  <- setdiff(colnames(texas[[1]]),
                                treatment.identifier)
times.dep  <- cbind("bmprison"  = c(1985,1993))

times.pred <- cbind("bmprison"  = c(1988,1989), #
                    "bmprison"  = c(1985,1986),
                    "alcohol"   = c(1985,1986), #
                    "aiscapita" = c(1985,1986),
                    "income"    = c(1985,1986),
                    "ur"        = c(1985,1986),
                    "poverty"   = c(1985,1986),
                    "black"     = c(1985,1986),
                    "perc1519"  = c(1985,1986)) #

agg.fns <- rep("mean", ncol(times.pred)) 

synth_texas <- mscmt(texas, treatment.identifier, 
                     controls.identifier, times.dep, 
                     times.pred, agg.fns, seed = 1)

path.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "bmprison", Xlab = "year",
          Ylim = c(10000,60000), Legend = c("Texas", "Synthetic Texas"), Legend.position = "bottomright")
abline(v=1993, col="blue", lty = 2,lwd = 2)



#%#%#%%#%%#%%#%#%%#%%#%%#%%#%%#%%$#$%#R%%#%%#%#%%#%%#%##
df.states = data.frame(state = state.name, stringsAsFactors = FALSE)
df.states = df.states[-which(df.states$state == "Arizona" |
                                              df.states$state == "Oregon" |
                                              df.states$state == "Florida" | 
                                              df.states$state == "Massachusetts" |
                                              df.states$state == "Alaska" |
                                              df.states$state == "Hawaii" |
                                              df.states$state == "Maryland" |
                                              df.states$state == "Michigan" |
                                              df.states$state == "New Jersey" |
                                              df.states$state == "New York" |
                                              df.states$state == "Washington"),]
df.states           = data.frame(count = c(1:39), df.states, stringsAsFactors = FALSE)
colnames(df.states) = c("state", "statename")

df.smoking = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/smoking.dta", convert.factors = FALSE)

df.smoking = merge(df.states, df.smoking, by = "state")

df.smoking <- listFromLong(df.smoking, unit.variable = "state", 
             time.variable="year", unit.names.variable = "statename")






####Huehuehueheuheuehuheueh####
treatment.identifier <- "California"
controls.identifier  <- setdiff(colnames(df.smoking[[1]]),
                                treatment.identifier)
times.dep  <- cbind("cigsale"  = c(1980,1988))

times.pred <- cbind("cigsale"    = c(1980,1988),
                    "age15to24"  = c(1980,1988),
                    "lnincome"   = c(1980,1988),
                     "retprice"  = c(1980,1988),
                     "beer"      = c(1984,1988),
                    "cigsale"    = c(1975,1975)) #

agg.fns <- rep("mean", ncol(times.pred)) 

synth_cali <- mscmt(df.smoking, treatment.identifier, 
                     controls.identifier, times.dep, 
                     times.pred, agg.fns, seed = 1)


library(ggplot2)
ggplot(synth_cali, type="comparison")
ggplot(synth_cali, type="gaps")

library(parallel)
cl <- makeCluster(2)

synth_cali <- mscmt(df.smoking, treatment.identifier, 
                     controls.identifier, times.dep, 
                     times.pred, agg.fns, placebo = TRUE, seed = 1)
stopCluster(cl)

ggplot(synth_cali, type = "comparison")
ggplot(synth_cali, exclude.ratio=5, ratio.type="rmspe") +
  geom_bar()









###**#*#*#*#*#*#


dataprep.out = dataprep(
  
  foo = df.smoking,
  predictors = c("cigsale", "lnincome", "age15to24", "retprice"),
  predictors.op = "mean",
  time.predictors.prior = 1980:1988,
  special.predictors = list(
    list("beer", 1984:1988, "mean"),
    list("cigsale", 1980, "mean"),
    list("cigsale",  1988, "mean"),
    list("cigsale",  1975, "mean")),
  dependent = "cigsale",
  unit.variable = "state",
  unit.names.variable = "statename",
  time.variable = "year",
  treatment.identifier = 3,
  controls.identifier = c(1,2,4:39),
  time.optimize.ssr = 1980:1988,
  time.plot = 1970:2000
)





  
  
