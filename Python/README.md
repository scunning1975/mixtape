# Notes on Python Implementation

Code outputs have been verified and match R output except in the following cases:

- **Differences_in_Differences.ipynb:** The design matrix in the Cunningham and Cornwell (2013) example is rank deficient. lm and lm_robust have a convergence issues. The problem seems to be with the fip variable. The statsmodels algorithm is more robust to rank deficiency resulting is different results
- **Matching_and_Subclassification.ipynb:** Python does not have an implementation of nearest neighbor matching in python. I may be possible to recreate one use standard KNN tools
- **Regression_Discontinuity.ipynb:** The smoothing and density section is missing

The majority of the models use the statmodels package. While I tried to limit my usage of R code through rpy2 I use it once for synthetic control matching.
