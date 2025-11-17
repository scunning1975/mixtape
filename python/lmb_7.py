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

def lm_robust(formula, data):
    regression = sm.OLS.from_formula(formula, data = data)
    regression = regression.fit(cov_type="cluster",cov_kwds={"groups":data['id']})
    return regression


lmb_data = read_data("lmb-data.dta")

lmb_data['demvoteshare_c'] = lmb_data['demvoteshare'] - 0.5
# drop missing values
lmb_data = lmb_data[~pd.isnull(lmb_data.demvoteshare_c)]
lmb_data['demvoteshare_sq'] = lmb_data['demvoteshare_c']**2

#aggregating the data
lmb_data = lmb_data[lmb_data.demvoteshare.between(.45, .55)]
categories = lmb_data.lagdemvoteshare
lmb_data['lagdemvoteshare_100'] = pd.cut(lmb_data.lagdemvoteshare, 100)

agg_lmb_data = lmb_data.groupby('lagdemvoteshare_100')['score'].mean().reset_index()
lmb_data['gg_group'] = [1 if x>.5 else 0 for x in lmb_data.lagdemvoteshare]
agg_lmb_data['lagdemvoteshare'] = np.arange(0.01, 1.01, .01)

# plotting
p.ggplot(lmb_data, p.aes('lagdemvoteshare', 'score')) +    p.geom_point(p.aes(x = 'lagdemvoteshare', y = 'score'), data = agg_lmb_data) +    p.stat_smooth(p.aes('lagdemvoteshare', 'score', group = 'gg_group'), 
                  data=lmb_data, method = "lm", 
              formula = 'y ~ x + I(x**2)') +\
    p.xlim(0,1) + p.ylim(0,100) +\
    p.geom_vline(xintercept = 0.5)

p.ggplot(lmb_data, p.aes('lagdemvoteshare', 'score')) +    p.geom_point(p.aes(x = 'lagdemvoteshare', y = 'score'), data = agg_lmb_data) +    p.stat_smooth(p.aes('lagdemvoteshare', 'score', group = 'gg_group'), 
                  data=lmb_data, method = "lowess") +\
    p.xlim(0,1) + p.ylim(0,100) +\
    p.geom_vline(xintercept = 0.5)

p.ggplot(lmb_data, p.aes('lagdemvoteshare', 'score')) +    p.geom_point(p.aes(x = 'lagdemvoteshare', y = 'score'), data = agg_lmb_data) +    p.stat_smooth(p.aes('lagdemvoteshare', 'score', group = 'gg_group'), 
                  data=lmb_data, method = "lm")+\
    p.xlim(0,1) + p.ylim(0,100) +\
    p.geom_vline(xintercept = 0.5)
