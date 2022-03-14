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


correct = pd.DataFrame({'cup': np.arange(1,9), 
                        'guess':np.concatenate((range(1,5), np.repeat(0, 4)))})

combo = pd.DataFrame(np.array(list(combinations(correct['cup'], 4))), 
                     columns=['cup_1', 'cup_2', 'cup_3', 'cup_4'])
combo['permutation'] = np.arange(70)
combo['key'] = 1
correct['key'] = 1
combo = pd.merge(correct, combo, on='key')
combo.drop('key', axis=1, inplace=True)
combo['correct'] = 0
combo.loc[(combo.cup_1==1) & 
          (combo.cup_2==2) & 
          (combo.cup_3==3) & 
          (combo.cup_4==4), 'correct'] = 1
combo = combo.sort_values(['permutation', 'cup'])

p_value = combo.correct.sum()/combo.shape[0]
p_value


