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



sasp = read_data("sasp_panel.dta")

#-- Delete all NA
sasp = sasp.dropna()

#-- order by id and session 
sasp.sort_values('id', inplace=True)


#Balance Data
times = len(sasp.session.unique())
in_all_times = sasp.groupby('id')['session'].apply(lambda x : len(x)==times).reset_index()
in_all_times.rename(columns={'session':'in_all_times'}, inplace=True)
balanced_sasp = pd.merge(in_all_times, sasp, how='left', on='id')
balanced_sasp = balanced_sasp[balanced_sasp.in_all_times]
balanced_sasp.shape

provider_second = np.zeros(balanced_sasp.shape[0])
provider_second[balanced_sasp.provider_second == "2. Yes"] = 1
balanced_sasp.provider_second = provider_second
balanced_sasp.reset_index(inplace=True, drop=True) 

#Demean Data

features = balanced_sasp.columns.to_list()
features = [x for x in features if x not in ['session', 'id', 'in_all_times']]
demean_features = ["demean_{}".format(x) for x in features]

balanced_sasp[demean_features] = balanced_sasp.groupby('id')[features].apply(lambda x : x - np.mean(x, axis=0)).reset_index()[features] 

##### Pooled OLS

dep_var = "+".join(features)
formula = """lnw ~ age + asq + bmi + hispanic + black + other + asian + schooling + cohab + 
            married + divorced + separated + age_cl + unsafe + llength + reg + asq_cl + 
            appearance_cl + provider_second + asian_cl + black_cl + hispanic_cl + 
           othrace_cl + hot + massage_cl"""
ols = sm.OLS.from_formula(formula, data=balanced_sasp).fit()
ols.summary()


# #### Fixed Effects

balanced_sasp['y'] = balanced_sasp.lnw

formula = """lnw ~ -1 + C(id) + age + asq + bmi + hispanic + black + other + asian + schooling + 
                      cohab + married + divorced + separated + 
                      age_cl + unsafe + llength + reg + asq_cl + appearance_cl + 
                      provider_second + asian_cl + black_cl + hispanic_cl + 
                      othrace_cl + hot + massage_cl"""

ols = sm.OLS.from_formula(formula, data=balanced_sasp).fit(cov_type='cluster', 
                                                           cov_kwds={'groups': balanced_sasp['id']})
ols.summary()    


# #### Demean OLS

#-- Demean OLS
dm_formula = """demean_lnw ~ demean_age + demean_asq + demean_bmi + 
                demean_hispanic + demean_black + demean_other +
                demean_asian + demean_schooling + demean_cohab + 
                demean_married + demean_divorced + demean_separated +
                demean_age_cl + demean_unsafe + demean_llength + demean_reg + 
                demean_asq_cl + demean_appearance_cl + 
                demean_provider_second + demean_asian_cl + demean_black_cl + 
                demean_hispanic_cl + demean_othrace_cl +
                demean_hot + demean_massage_cl"""

ols = sm.OLS.from_formula(dm_formula, data=balanced_sasp).fit(cov_type='cluster', cov_kwds={'groups': balanced_sasp['id']})

ols.summary()  

