use https://github.com/scunning1975/mixtape/raw/master/castle.dta, clear
* ssc install bacondecomp

* define global macros
global crime1 jhcitizen_c jhpolice_c murder homicide  robbery assault burglary larceny motor robbery_gun_r 
global demo blackm_15_24 whitem_15_24 blackm_25_44 whitem_25_44 //demographics
global lintrend trend_1-trend_51 //state linear trend
global region r20001-r20104  //region-quarter fixed effects
global exocrime l_larceny l_motor // exogenous crime rates
global spending l_exp_subsidy l_exp_pubwelfare
global xvar l_police unemployrt poverty l_income l_prisoner l_lagprisoner $demo $spending
global law cdl  

* Bacon decomposition
net install ddtiming, from(https://tgoldring.com/code/)
areg l_homicide post i.year, a(sid) robust
ddtiming l_homicide post, i(sid) t(year)

