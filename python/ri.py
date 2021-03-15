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




ri = read_data('ri.dta')
ri['id'] = range(1,9)
treated = range(1,5)

combo = pd.DataFrame(np.array(list(combinations(ri['id'], 4))), 
                     columns=['treated1', 'treated2', 'treated3', 'treated4'])
combo['permutation'] = np.arange(1,71)

combo['key'] = 1
ri['key'] = 1
combo = pd.merge(ri, combo, on='key')
combo.drop('key', axis=1, inplace=True)
combo = combo.sort_values(['permutation', 'name'])

combo['d'] = 0
combo.loc[(combo.treated1==combo.id) | 
          (combo.treated2==combo.id) | 
          (combo.treated3==combo.id) | 
          (combo.treated4==combo.id), 'd'] = 1

te1 = combo[combo.d==1].groupby('permutation')['y'].mean()
te0 = combo[combo.d==0].groupby('permutation')['y'].mean()

n = pd.merge(te1, te0, how='inner', on="permutation").shape[0]

p_value = pd.merge(te1, te0, how='inner', on="permutation")
p_value.columns = ['te1', 'te0']
p_value = p_value.reset_index()
p_value['ate'] = p_value['te1'] - p_value['te0']
p_value = p_value.sort_values(by='ate', ascending=False)
p_value['rank'] = range(1, p_value.shape[0]+1)
p_value = p_value[p_value['permutation'] == 1]
p_value['rank'] / n


