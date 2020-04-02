## Update by Grant McDermott

## Libraries (skipping some libraries for this iteration)
library(readstata13)
library(Synth)
# library(gsynth)
# library(MSCMT)

#For the placebo inference using the classical synth package, we use sctools, which needs
#devtools for installation:
#%# library(devtools)
#%# install_github("bcastanho/SCtools")

library(SCtools)


#Uploading the file
texas <- read.dta13("texas.dta")


####Using the Synth Package####
dataprep.out = dataprep(
  foo = texas,
  predictors = c("poverty", "income", "ur"),
  predictors.op = "mean",
  time.predictors.prior = 1985:1993,
  special.predictors = list(
    list("bmprison", 1988, "mean"),
    list("alcohol", 1990, "mean"),
    list("aidscapita",  1990:1991, "mean"),
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

synth.out = synth(data.prep.obj = dataprep.out)

## PLACEBOS

## The below code fails on the 34th iteration (i.e. North Carolina), because
## the synth() optimization tolerance level needs to be adjusted via the
## `Sigf.out` argument.
# placebos = generate.placebos(dataprep.out, synth.out)

## While I won't repeat that here, isolating North Carolina on its own suggests
## that Sigf.out = 3` works... But, the current generate.placebos() function 
## doesn't allow for additional synth() arguments. We should submit a PR to the 
## SCtools repo afterwards, but for now we'll just roll our own quick version:

# library(stringr) ## Already loaded  with the SCtools library
source("generate_placebos.R")
system.time({
  placebos = generate_placebos(dataprep.out, synth.out, Sigf.ipop = 3)
})




## Save for later if we want them
save.image("~/Documents/Projects/remix-synth/placebos.RData")

plot.placebos(placebos) +
  ggsave("placebos.png", width=7, height=5)
