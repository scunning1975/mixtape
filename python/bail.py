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
	return pd.read_stata("https://raw.github.com/scunning1975/mixtape/master/" + file)


judge = read_data("judge_fe.dta")
judge['bailDate'] = (judge['bailDate'] - pd.to_datetime('1970-01-01')).dt.days.values

# grouped variable names from the data set
judge_pre = "+".join(judge.columns[judge.columns.str.contains('^judge_pre_[1-7]')])
demo = "+".join(['black', 'age', 'male', 'white'])
off = "+".join(['fel', 'mis', 'sum', 'F1', 'F2', 'F3', 'M1', 'M2', 'M3', 'M'])
prior = "+".join(['priorCases', 'priorWI5', 'prior_felChar', 'prior_guilt', 'onePrior', 'threePriors'])
control2 = "+".join(['day', 'day2', 'bailDate', 't1', 't2', 't3', 't4', 't5'])

#formulas used in the OLS
min_formula = "guilt ~ jail3 + " + control2
max_formula = """guilt ~ jail3 + possess + robbery + DUI1st + drugSell + 
                aggAss + {demo} + {prior} + {off} + {control2}""".format(demo=demo,
                                                                        prior=prior,
                                                                        off=off,
                                                                        control2=control2)

#max variables and min variables
min_ols = sm.OLS.from_formula(min_formula, data = judge).fit()
max_ols = sm.OLS.from_formula(max_formula, data = judge).fit()
print("OLS")
Stargazer([min_ols, max_ols])



#--- Instrumental Variables Estimations
#-- 2sls main results
#- Min and Max Control formulas

min_formula = "guilt ~ {control2} + [jail3 ~ {judge_pre}]".format(control2=control2, judge_pre=judge_pre)
max_formula = """guilt ~ {demo} + possess + {prior} + robbery + {off} + DUI1st + {control2} + drugSell + aggAss +
                    [jail3 ~ {judge_pre}]""".format(demo=demo,
                                                    prior=prior,
                                                    off=off,
                                                    control2=control2,
                                                   judge_pre=judge_pre)

min_iv = IV2SLS.from_formula(min_formula, data = judge).fit()
max_iv = IV2SLS.from_formula(max_formula, data = judge).fit()


print("IV")
min_iv.summary
max_iv.summary


#-- JIVE main results
#- minimum controls

from rpy2 import robjects
from rpy2.robjects import pandas2ri
from rpy2.robjects.packages import importr
pandas2ri.activate()
SteinIV = importr('SteinIV')

y = judge['guilt']
X_min = judge[['jail3', 'day', 'day2', 't1', 't2', 't3', 't4', 't5', 'bailDate']]
X_min['intercept'] = 1

Z_min = judge[judge_pre.split('+') + ['day', 'day2', 't1', 't2', 't3', 't4', 't5', 'bailDate']]
Z_min['intercept'] = 1


y = robjects.globalenv['y'] = y
X_min = robjects.globalenv['X_min'] = np.array(X_min)
Z_min = robjects.globalenv['Z_min'] = np.array(Z_min)

SteinIV.jive_est(y = y, X=X_min, Z=Z_min)

#- maximum controls
X_max = judge[['jail3', 'white', 'age', 'male', 'black',
         'possess', 'robbery', 
         'prior_guilt', 'onePrior', 'priorWI5', 'prior_felChar', 'priorCases',
         'DUI1st', 'drugSell', 'aggAss', 'fel', 'mis', 'sum',
         'threePriors',
         'F1', 'F2', 'F3',
         'M', 'M1', 'M2', 'M3',
         'day', 'day2', 'bailDate', 
         't1', 't2', 't3', 't4', 't5']]
X_max['intercept'] = 1

Z_max = judge[judge_pre.split('+') + ['white', 'age', 'male', 'black',
         'possess', 'robbery', 
         'prior_guilt', 'onePrior', 'priorWI5', 'prior_felChar', 'priorCases',
         'DUI1st', 'drugSell', 'aggAss', 'fel', 'mis', 'sum',
         'threePriors',
         'F1', 'F2', 'F3',
         'M', 'M1', 'M2', 'M3',
         'day', 'day2', 'bailDate', 
         't1', 't2', 't3', 't4', 't5']]
Z_max['intercept'] = 1
X_max = robjects.globalenv['X_max'] = np.array(X_max)
Z_max = robjects.globalenv['Z_max'] = np.array(Z_max)


SteinIV.jive_est(y = y, X = X_max, Z = Z_max)


