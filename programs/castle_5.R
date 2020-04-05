library(bacondecomp)
library(lfe)

df_bacon <- bacon(l_homicide ~ post,
                  data = castle, id_var = "state",
                  time_var = "year")

summary(df_bacon)


# create formula
# drop one additional region variable due to colinearity
formula <- as.formula(
  paste("l_homicide ~ post + lead9 + lead8 + lead7 + ",
        "lead6 + lead5 + lead4 + lead3 + lead2 + lead1 + ",
        "lag1 + lag2 + lag3 + lag4 + lag5 + ",
        paste(
          paste(xvar, collapse = " + "),
          paste(subset(region, region != 'r20003'), 
                collapse = " + "),
          paste(lintrend, collapse = " + "), sep = " + "),
        "| year + sid"
  )
)

reg <- felm(formula = formula, data = castle)
summary(reg)


