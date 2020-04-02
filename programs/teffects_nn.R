library(MatchIt)
library(Zelig)

m_out <- matchit(treat ~ age + agesq + agecube + educ +
                 educsq + marr + nodegree +
                 black + hisp + re74 + re75 + u74 + u75 + interaction1,
                 data = nsw_dw_cpscontrol, method = "nearest", 
                 distance = "logit", ratio =5)

m_data <- match.data(m_out)

z_out <- zelig(re78 ~ treat + age + agesq + agecube + educ +
               educsq + marr + nodegree +
               black + hisp + re74 + re75 + u74 + u75 + interaction1, 
               model = "ls", data = m_data)

x_out <- setx(z_out, treat = 0)
x1_out <- setx(z_out, treat = 1)

s_out <- sim(z_out, x = x_out, x1 = x1_out)

summary(s_out)
