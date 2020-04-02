#Remix - Synthetic Control
#October 11
#hsr

#--- Page 364 ...black prison example
library(tidyverse)
library(readstata13)
library(Synth)

library(devtools)
devtools::install_github("bcastanho/SCtools")
library(SCtools)

texas <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/texas.dta")

dataprep_out <- dataprep(
  foo = texas,
  predictors = c("poverty", "ur", "income"),
  predictors.op = "mean",
  time.predictors.prior = 1985:1993,
  special.predictors = list(
    list("bmprison", c(1988, 1990:1992), "mean"),
    list("alcohol", 1990, "mean"),
    list("aidscapita", 1990:1991, "mean"),
    list("black", 1990:1992, "mean"),
    list("perc1519", 1990, "mean")),
  dependent = "bmprison",
  unit.variable = "statefip",
  unit.names.variable = "state",
  time.variable = "year",
  treatment.identifier = 48,
  controls.identifier = c(1,2,4:6,8:13,15:42,44:47,49:51,53:56),
  time.optimize.ssr = 1985:1993,
  time.plot = 1985:2000
)

synth_out <- synth(data.prep.obj = dataprep_out)
synth_tables <- synth.tab(dataprep.res = dataprep_out, synth.res = synth_out)
synth_tables$tab.w

path.plot(synth_out, dataprep_out)
gaps.plot(synth_out, dataprep_out)

#--- Page 366 ...placebo
system.time({
  placebos <- generate.placebos(dataprep_out, synth_out, Sigf.ipop = 3)
})

plot.placebos(placebos)
mspe.plot(placebos, discard.extreme = TRUE, mspe.limit = 1, plot.hist = TRUE)


