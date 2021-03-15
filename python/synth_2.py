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



texas = read_data("texas.dta")


from rpy2.robjects.packages import importr
from rpy2.robjects.conversion import localconverter
Synth = importr('Synth')


control_units = [1, 2, 4, 5, 6] +    list(range(8, 14)) + list(range(15,43)) +    list(range(44, 47)) + [49, 50, 51, 53,54,55,56]

robjects.globalenv['texas'] = texas

predictors = robjects.vectors.StrVector(['poverty', 'income'])
sp = robjects.vectors.ListVector({'1': ['bmprison', IntVector([1988, 1990, 1991, 1992]), 'mean'], 
                                  '2': ['alcohol', 1990, 'mean'], 
                                  '3': ['aidscapita', IntVector([1990, 1991]), 'mean'], 
                                  '4': ['black', IntVector([1990, 1991, 1992]), 'mean'], 
                                  '5': ['perc1519', 1990, 'mean']})

dataprep_out = Synth.dataprep(texas, 
    predictors = predictors,
    predictors_op="mean",
    time_predictors_prior=np.arange(1985, 1994),
    special_predictors=sp,
    dependent='bmprison',
    unit_variable='statefip',
    unit_names_variable='state',
    time_variable='year',
    treatment_identifier=48,
    controls_identifier=control_units,
    time_optimize_ssr=np.arange(1985, 1994),
    time_plot=np.arange(1985, 2001))

synth_out = Synth.synth(data_prep_obj = dataprep_out)


weights = synth_out.rx['solution.w'][0]
ct_weights = pd.DataFrame({'ct_weights':weights.flatten(), 'statefip':control_units})
ct_weights.head()

texas = pd.merge(ct_weights, texas, how='right', on='statefip')

texas = texas.sort_values('year')
ct = texas.groupby('year').apply(lambda x : np.sum(x['ct_weights']*x['bmprison']))
treated = texas[texas.statefip==48]['bmprison'].values
years = texas.year.unique()




ct_diff = treated - ct

plt.plot(years, np.zeros(len(years)), linestyle='--', color='black', label='control')
plt.plot(years, ct_diff, linestyle='-', color='black', label='treated')
plt.ylabel('bmprison')
plt.xlabel('Time')
plt.title('Treated - Control')




