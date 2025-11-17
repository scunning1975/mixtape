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

abortion = read_data('abortion.dta')
abortion = abortion[~pd.isnull(abortion.lnr)]

abortion_filt = abortion[(abortion.race == 2) & (abortion.sex == 2) & (abortion.age == 20)]

regdd = (
    smf
    .wls("""lnr ~ C(repeal)*C(year) + C(fip) + acc + ir + pi + alcohol+ crack + poverty+ income+ ur""", 
        data=abortion_filt, weights=abortion_filt.totpop.values)
    .fit(
        cov_type='cluster', 
        cov_kwds={'groups': abortion_filt.fip.values}, 
        method='pinv')
)

regdd.summary()

