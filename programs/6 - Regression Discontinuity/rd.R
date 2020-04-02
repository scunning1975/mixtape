# RDD
# Hugo Rodrigues
# August 2019


library(tidyverse) #for ggplot and tibble
library(skimr) #for the skim function
#library(hrbrthemes) #For the ipsum palette
library(magrittr) # %<>%
library(readstata13)
library(estimatr) # cluster
library(stringr) # regex
library(dummies)
library(rddapp)
library(stats)

# simulate the data
dat <- tibble(
  x = rnorm(1000, 50, 25)
) %>%
  mutate(
    x = if_else(x < 0, 0, x)
  ) %>%
  filter(x < 100)
skim(dat)

# cutoff at x = 50
dat %<>% 
  mutate(
    D  = if_else(x > 50, 1, 0),
    y1 = 25 + 0 * D + 1.5 * x + rnorm(n(), 0, 20)
  )

# figure 35
ggplot(aes(x, y1, colour = factor(D)), data = dat) +
  geom_point(alpha = 0.5) +
  geom_vline(xintercept = 50, colour = "grey", linetype = 2)+
  stat_smooth(method = "lm", se = F) +
  #scale_colour_ipsum(name = "Treatment") +
  labs(x = "Test score (X)", y = "Potential Outcome (Y1)")
 # theme_ipsum()
  
  # simulate the discontinuity
  dat %<>%
    mutate(
      y2 = 25 + 40 * D + 1.5 * x + rnorm(n(), 0, 20)
    )
  
  # figure 36
  ggplot(aes(x, y2, colour = factor(D)), data = dat) +
    geom_point(alpha = 0.5) +
    geom_vline(xintercept = 50, colour = "grey", linetype = 2) +
    stat_smooth(method = "lm", se = F) +
    #scale_colour_ipsum(name = "Treatment") +
    labs(x = "Test score (X)", y = "Potential Outcome (Y)")
    #theme_ipsum()

  # simultate nonlinearity
  dat %<>%
    mutate(
      y3 = 25 + 0 * D + 2 * x + x ^ 2 + rnorm(n(), 0, 20)
    )
  
  # figure 36
  ggplot(aes(x, y3, colour = factor(D)), data = dat) +
    geom_point(alpha = 0.5) +
    geom_vline(xintercept = 50, colour = "grey", linetype = 2) +
    #scale_colour_ipsum(name = "Treatment") +
    labs(x = "Test score (X)", y = "Potential Outcome (Y)")
    #theme_ipsum()
  
  # page 194
  dat%<>%
    mutate(
      x2 = x*x,
      x3 = x*x*x,
      y =  10000 + 0*D - 100*x + x2 + rnorm(n(), 0, 1000),
      y_pred = predict(lm(y ~ x2 + x3 + D + x, data = dat))
    )
  
  #-----------%
  ggplot(aes(x, y, colour = factor(D)), data = dat) +
    geom_point(alpha = 0.5) +
    geom_vline(xintercept = 50, colour = "grey", linetype = 2) +
    #scale_colour_ipsum(name = "Treatment") +
    labs(x = "Test score (X)", y = "Potential Outcome (Y)")
   # theme_ipsum()
  #-----------%
  #Never plotted this in the book.
  
  
  # page 187
  lmb_data <- read.dta13("~/Dropbox/Mixtape/Workshop/mixtape_datafiles/data/lmb-data.dta")
  
  lmb_subset <- subset(lmb_data, lagdemvoteshare>.48
                                & lagdemvoteshare<.52) 
  
  lm_1 <- lm_robust(score ~ lagdemocrat, data = lmb_subset, clusters = id)
  lm_2 <- lm_robust(score ~ democrat, data = lmb_subset, clusters = id)
  lm_3 <- lm_robust(democrat ~ lagdemocrat, data = lmb_subset, clusters = id)
  
  tidy(lm_1)
  tidy(lm_2)
  tidy(lm_3)
  
  
  lm_4 <- lm_robust(score ~ democrat, data = lmb_data, clusters = id2)

  tidy(lm_4)
  
  lm_5 <- lmb_data %>% 
    mutate(demvoteshare_c = demvoteshare - 0.5) %>% 
    lm_robust(score ~ democrat + demvoteshare_c, clusters = id2, data = .)
  
  tidy(lm_5)
  
  
  # loop part
  lm_6 <- lm_robust(score ~ democrat*demvoteshare_c, 
                    data = lmb_data,
                    clusters = id2)
  
  tidy(lm_6)
  
  # loop part 2
  lmb_subset <- subset(lmb_data, demvoteshare>.45
                       & demvoteshare<.55) 
  
  lm_7 <- lmb_data %>% 
    filter(demvoteshare > .45 & demvoteshare < .55) %>% 
    lm_robust(score ~ democrat*demvoteshare_c, 
                    data = .,
                    clusters = id2)
  
  tidy(lm_7)
  
  # page 193
  lm_8 <- lmb_data %>% 
    mutate(x_c = demvoteshare - 0.5,
           x_c2 = x_c^2
    ) %>% 
    lm_robust(score ~ democrat*x_c + democrat*x_c2, data = .)
  
  tidy(lm_8)
  
  # page 193 - part 2
  lm_9 <- lmb_data %>% 
    mutate(x_c = demvoteshare - 0.5,
           x_c2 = x_c^2
    ) %>%
    filter(demvoteshare>0.4 & demvoteshare<0.6) %>% 
    lm_robust(score ~ democrat*(x_c + x_c2), data = .)
  
  lm_9
  
  # figure 5
  
  ggplot(lmb_data, aes(lagdemvoteshare, score)) +
    geom_point() +
    stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "lm", 
                formula = y ~ x + I(x^2)) +
    xlim(0,1) + ylim(0,100) +
    geom_vline(xintercept = 0.5)
  
  ggplot(agg_lmb_data, aes(lagdemvoteshare, score)) +
    geom_point() +
    stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "loess") +
    xlim(0,1) + ylim(0,100) +
    geom_vline(xintercept = 0.5)
  
  ggplot(agg_lmb_data, aes(lagdemvoteshare, score)) +
    geom_point() +
    stat_smooth(aes(lagdemvoteshare, score, group = gg_group), method = "lm") +
    xlim(0,1) + ylim(0,100) +
    geom_vline(xintercept = 0.5)
  
  
  #### Rest of the plots  - Do File
  
  
  
  install.packages("RStata")

  
  
  
  
  
  