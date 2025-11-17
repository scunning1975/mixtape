#- Analysis of Clustered Data - part 4
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

#clustered robust
sim_params <- c(.4, 0)   # beta1 = 0: no effect of x on y
sim_cluster_robust <- run_cluster_sim(n_sims = 10000, param = sim_params,
                                      cluster_robust = TRUE)

hist_cluster_robust <- hist_nocluster %+% sim_cluster_ols
print(hist_cluster_robust)

#Confidence Intervals
ci95_cluster_robust <- ci95_nocluster %+% sample_n(sim_cluster_robust, 100)
print(ci95_cluster_robust)

sim_cluster_robust %>% summarize(type1_error = 1 - sum(param_caught)/n())
