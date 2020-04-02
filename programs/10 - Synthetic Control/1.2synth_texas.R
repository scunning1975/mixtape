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



texas <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/texas.dta")

#%#%#%#%#% TEMPORARY#%#%#%#%#
setwd("~/Documents/Mestrado/Remix")
state_ansi_fips <- read_csv("./us-state-ansi-fips.csv")
colnames(state_ansi_fips) <- c("state_name", "statefip", "acron")
state_ansi_fips$statefip <- as.numeric(state_ansi_fips$statefip) 
texas <- merge(texas, state_ansi_fips)
#%#%#%#%#%#%#%#%#%%##%%#%#%##

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


  
  
  

## ------------------------------------------------------------------------
res <- mscmt(Basque, treatment.identifier, controls.identifier, times.dep, times.pred, agg.fns, seed=1)

length(texas[texas$statefip==48,])
nrow(texas[texas$statefip==48,])
sum(is.na(texas[(texas$statefip==18),]))

dataprep.out = dataprep(
  
  foo = texas,
  predictors = c("income","ur","poverty"),
  time.predictors.prior = 1985:1993,
  special.predictors = list(
    list("income", 1990, "mean"),
    list("ur", 1990, "mean"),
    list("poverty", 1990, "mean"),
    list("bmprison", c(1988,1990:1992), "mean"),
    list("alcohol", 1990, "mean"),
    list("aidscapita",  1990:1991, "mean"),
    list("black", 1991:1992, "mean"),
    list("perc1519", 1990, "mean")),
  dependent = "bmprison",
  unit.variable = "statefip",
  unit.names.variable = "state",
  time.variable = "year",
  treatment.identifier = 5,
  controls.identifier = unique(setdiff(texas$statefip, c(48,5,1))),
  time.optimize.ssr = 1985:1993,
  time.plot = 1985:2000
)

#Generating Synth Texas
synth.out = synth(data.prep.obj = dataprep.out, method = "BFGS")



dataprep.out$X0

#P.304_Fig107: African-American Male Incarceration 
path.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "bmprison", Xlab = "year",
          Ylim = c(10000,60000), Legend = c("Texas", "Synthetic Texas"), Legend.position = "bottomright")
abline(v=1993, col="blue", lty = 2,lwd = 2)

#P.305_Figure 108: Gap between actual Texas and synthetic Texas
gaps.plot(synth.res = synth.out, dataprep.res = dataprep.out,
          Ylab = "Gap in black male prisoner prediction error", Xlab = "year",
          Ylim = c(-2000,30000), Main = NA)
abline(v=1993, col="blue", lty = 2,lwd = 2)

synth.tables = synth.tab(dataprep.res = dataprep.out, synth.res = synth.out)


#P.305_Table 36: Synthetic control weights
synth.tables$tab.w
synth.tables$tab.v

#Placebo
placebos = generate.placebos(dataprep.out, synth.out)
plot.placebos(placebos, mspe.limit = 20, discard.extreme = TRUE)


#MSPE
mspe.plot(placebos, plot.hist = FALSE)


synth.out$solution.v

dataprep.out$Z1
synth.out$rgV.optim

Arkansas = texas[texas$statefip==5,]




MSCMT::mscmt()

browseVignettes(package="MSCMT")
  
  

