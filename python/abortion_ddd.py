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




abortion = read_data('abortion.dta')
abortion = abortion[~pd.isnull(abortion.lnr)]

abortion['yr'] = 0
abortion.loc[(abortion.younger==1) & (abortion.repeal==1), 'yr'] = 1

abortion['wm'] = 0
abortion.loc[(abortion.wht==1) & (abortion.male==1), 'wm'] = 1

abortion['wf'] = 0
abortion.loc[(abortion.wht==1) & (abortion.male==0), 'wf'] = 1

abortion['bm'] = 0
abortion.loc[(abortion.wht==0) & (abortion.male==1), 'bm'] = 1

abortion['bf'] = 0
abortion.loc[(abortion.wht==0) & (abortion.male==0), 'bf'] = 1


abortion_filt = abortion[(abortion.bf==1) & (abortion.age.isin([15,25]))]

reg = (
    smf
    .wls("""lnr ~ C(repeal)*C(year) + C(younger)*C(repeal) + C(younger)*C(year) + 
C(yr)*C(year) + C(fip)*t + acc + ir + pi + alcohol + crack + poverty + income + ur""", 
        data=abortion_filt, weights=abortion_filt.totpop.values)
    .fit(
        cov_type='cluster', 
        cov_kwds={'groups': abortion_filt.fip.values}, 
        method='pinv')
)

abortion_plot = pd.DataFrame({'sd': reg.bse['C(yr)[T.1]:C(year)[T.1986.0]':'C(yr)[T.1]:C(year)[T.2000.0]'],
             'mean': reg.params['C(yr)[T.1]:C(year)[T.1986.0]':'C(yr)[T.1]:C(year)[T.2000.0]'],
             'year':np.arange(1986, 2001)})

abortion_plot['lb'] = abortion_plot['mean'] - abortion_plot['sd']*1.96
abortion_plot['ub'] = abortion_plot['mean'] + abortion_plot['sd']*1.96


p.ggplot(abortion_plot, p.aes(x = 'year', y = 'mean')) +     p.geom_rect(p.aes(xmin=1986, xmax=1991, ymin=-np.inf, ymax=np.inf), fill = "cyan", alpha = 0.01)+    p.geom_point()+    p.geom_text(p.aes(label = 'year'), ha='right')+    p.geom_hline(yintercept = 0) +    p.geom_errorbar(p.aes(ymin = 'lb', ymax = 'ub'), width = 0.2,
                position = p.position_dodge(0.05)) +\
    p.labs(title= "Estimated effect of abortion legalization on gonorrhea")
