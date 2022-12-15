import numpy as np 
import pandas as pd 
import statsmodels.api as sm 
import statsmodels.formula.api as smf 
from itertools import combinations 
import plotnine as p

# read data
import ssl
ssl._create_default_https_context = ssl._create_unverified_context
def read_data(file): 
	return pd.read_stata("https://github.com/scunning1975/mixtape/raw/master/" + file)


training_bias_reduction = read_data("training_bias_reduction.dta") 

training_bias_reduction['Y1'] = 0
training_bias_reduction.loc[training_bias_reduction['Unit'].isin(range(1,5)), 'Y1'] = 1
training_bias_reduction['Y0'] = (4,0,5,1,4,0,5,1)


train_reg = sm.OLS.from_formula('Y ~ X', training_bias_reduction).fit()
training_bias_reduction['u_hat0'] = train_reg.predict(training_bias_reduction)
training_bias_reduction = training_bias_reduction[['Unit', 'Y1', 'Y0', 'Y', 'D', 'X', 'u_hat0']]

training_bias_reduction



