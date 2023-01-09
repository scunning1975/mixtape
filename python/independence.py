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



def gap():
    sdo = pd.DataFrame({
        'y1': (7, 5, 5, 7, 4, 10, 1, 5, 3, 9),
        'y0' : (1, 6, 1, 8, 2, 1, 10, 6, 7, 8),
        'random' : np.random.normal(size=10)})
    sdo.sort_values('random', inplace=True)
    sdo['d'] = [1,1,1,1,1,0,0,0,0,0]
    sdo['y'] = sdo['d']*sdo['y1'] + (1-sdo['d'])*sdo['y0']

    sdo = np.mean(sdo.y.values[0:5] - sdo.y.values[5:10])

    return sdo


sim = [gap() for x in range(1000)]
np.mean(sim)

