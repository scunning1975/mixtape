#- Analysis of Clustered Data - part 3
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

#Confidence interval
ci95_cluster_ols <- ci95_nocluster %+% sample_n(sim_cluster_ols, 100)
print(ci95_cluster_ols)

sim_cluster_ols %>% summarize(type1_error = 1 - sum(param_caught)/n())
