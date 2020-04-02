library(tidyverse)
library(haven)
library(ipw)

read_data <- function(df)
{
  full_path <- paste("https://raw.github.com/scunning1975/mixtape/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}

#continuation
nsw_dw_cpscontrol_BACKUP <- nsw_dw_cpscontrol

nsw_dw_cpscontrol <- nsw_dw_cpscontrol %>%
  mutate(re78_scaled = re78/10000)


ipw <- ipwpoint(exposure = treat, 
         family = "binomial", 
         link = "logit",
         denominator = ~ re78_scaled + age + agesq + agecube + 
           educ + educsq + marr + nodegree + 
           black + hisp + re74 + re75 + u74 + interaction1,
         data = nsw_dw_cpscontrol)


#NOT WORKING# #DO NOT USE IT#