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



tb = pd.DataFrame({
    'd' : np.concatenate((np.repeat(0, 20), np.repeat(1, 20))),
    'y' : (
        0.22, -0.87, -2.39, -1.79, 0.37, -1.54,
        1.28, -0.31, -0.74, 1.72,
        0.38, -0.17, -0.62, -1.10, 0.30,
        0.15, 2.30, 0.19, -0.50, -0.9,
        -5.13, -2.19, 2.43, -3.83, 0.5,
        -3.25, 4.32, 1.63, 5.18, -0.43,
        7.11, 4.87, -3.10, -5.81, 3.76,
        6.31, 2.58, 0.07, 5.76, 3.50
    )})

p.ggplot() +    p.geom_density(tb, p.aes(x='y', color='factor(d)')) +    p.xlim(-7, 8) +    p.labs(title = "Kolmogorov-Smirnov Test") +    p.scale_color_discrete(labels = ("Control", "Treatment"))

