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


hiv = read_data("thornton_hiv.dta")
# creating the permutations

def permuteHIV(df, random = True):
    tb = df.copy()
    n_treated = 2222
    n_control = tb.shape[0] - n_treated
    if random:
        tb = tb.sample(frac=1)
        tb['any'] = np.concatenate((np.repeat(1, n_treated), np.repeat(0, n_control)))
    
    te1 = tb[tb['any']==1]['got'].mean()
    te0 = tb[tb['any']==0]['got'].mean()
    
    
    ate = te1 - te0
    return ate

print(permuteHIV(hiv, random = False))
iterations = 1000
permutation = pd.DataFrame({
    'iteration': range(iterations),
    'ate' : [permuteHIV(hiv, random=False), 
                            *[permuteHIV(hiv, random=True) for x in range(iterations-1)]]}
)
# calculating the p-value

permutation = permutation.sort_values('ate', ascending=False)
permutation['rank'] = np.arange(1, iterations+1)
p_value = permutation[permutation.iteration==0]['rank'].astype(float) / iterations
print(p_value)




