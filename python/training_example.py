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



training_example = read_data("training_example.dta") 

p.ggplot(training_example, p.aes(x='age_treat')) +  p.stat_bin(bins = 10)


p.ggplot(training_example, p.aes(x='age_control')) +  p.geom_histogram(bins = 10)


