#- Analysis of Clustered Data - part 2
#- Courtesy of Dr. Yuki Yanai, 
#- http://yukiyanai.github.io/teaching/rm1/contents/R/clustered-data-analysis.html

library('arm')
library('mvtnorm')
library('lme4')
library('multiwayvcov')
library('clusterSEs')
library('ggplot2')
library('dplyr')
library('haven')

#Data with clusters
sim_params <- c(.4, 0)   # beta1 = 0: no effect of x on y
sim_cluster_ols <- run_cluster_sim(n_sims = 10000, param = sim_params)
hist_cluster_ols <- hist_nocluster %+% sim_cluster_ols
print(hist_cluster_ols)