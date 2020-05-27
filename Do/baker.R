---
title: 'Difference-in-Differences: What it DiD?'
author: "Andrew Baker"
institute: "Stanford University"
date: "`r Sys.Date()`"
header_includes:
  - \usepackage{animate}
output:
  xaringan::moon_reader:
    lib_dir: libs
    nature:
      highlightStyle: github
      highlightLines: true
      countIncrementalSlides: false
      extra_dependencies: ["xcolor"]
      ratio: "16:9"
---
```{css, echo = FALSE}
@media print {
  .has-continuation {
    display: block !important;
  }
}
```

```{r setup, include=FALSE}
knitr::opts_chunk$set(fig.retina = 2)
```
```{r, message = FALSE, warning = FALSE, echo = FALSE}
library(tidyverse)
library(kableExtra)
library(here)
library(ggthemes)
library(lfe)
library(did2)
library(xaringan)
library(patchwork)
library(bacondecomp)
library(multcomp)
library(fastDummies)
library(magrittr)
library(MCPanel)
library(gganimate)
library(gifski)

select <- dplyr::select
theme_set(theme_clean() + theme(plot.background = element_blank()))

```

# .center.pull[Outline of Talk]

$\hspace{2cm}$

1. Overview of DiD

2. Problems with Staggered DiD

3. Simulation Results

4. Some Alternative Methods

5. Application

---
# .center.pull[Difference-in-Differences]

$\hspace{2cm}$

- Think Card and Krueger minimum wage study comparing NJ and PA.

- 2 units and 2 time periods.

- 1 unit (T) is treated, and receives treatment in the second period. The control unit (C) is never treated. 



---

# .center.pull[Difference-in-Differences]

```{r d1, echo = FALSE, fig.align = 'center', fig.width = 10, cache = TRUE}
# make data
data <- tibble(
  Y = c(2, 5, 1, 2),
  Unit = c("Treat", "Treat", "Control", "Control"),
  T = c(0, 1, 0, 1)
)

# plot
data %>% 
  ggplot(aes(x = T, y = Y, group = Unit, color = Unit)) + geom_line(size = 2) + 
  labs(x = "Time", y = "Outcome") + 
  scale_x_continuous(breaks = c(0, 1)) + 
  scale_colour_brewer(palette = 'Set1') + 
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 16),
        legend.position = 'bottom',
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        plot.background = element_blank())

```


---

# .center.pull[Difference-in-Differences]

- Building upon $\color{blue}{\text{Angrist & Pischke (2008, p. 228)}}$ we can think of these simple 2x2 DiDs as a fixed effects estimator.

- Potential Outcomes 
  - $Y_{i, t}^1$ = value of dependent variable for unit $i$ in period $t$ with treatment.
  - $Y_{i, t}^0$ = value of dependent variable for unit $i$ in period $t$ without treatment.
  
- The expected outcome is a *linear function* of unit and time fixed effects:
$$E[{Y_{i, t}^0}] =\alpha_i + \alpha_t$$
$$E[{Y_{i, t}^1}] =\alpha_i + \alpha_t + \delta D_{st}$$
- Goal of DiD is to get an unbiased estimate of the treatment effect $\delta$.


---
# .center.pull[Difference-in-Differences as Solving System of Equations for Unknown Variable]

- Difference in expectations for the *control* unit times t = 1 and t = 0:
$$\begin{align*} E[Y_{C, 1}^0] & = \alpha_1 + \alpha_C \\ E[Y_{C, 0}^0] & = \alpha_0 + \alpha_C  \\ E[Y_{C, 1}^0] - E[Y_{C, 0}^0] & = \alpha_1 - \alpha_0 \end{align*}$$
 
- Now do the same thing for the *treated* unit:
   $$\begin{align*} E[Y_{T, 1}^1] & = \alpha_1 + \alpha_T + \delta \\ E[Y_{T, 0}^1] & = \alpha_0 + \alpha_T  \\ E[Y_{T, 1}^1] - E[Y_{T, 0}^1] & = \alpha_1 - \alpha_0 + \delta \end{align*}$$
- If we assume the linear structure of DiD, then unbiased estimate of $\delta$ is:

$$\delta=
    \begin{align*} & \left( E[Y_{T, 1}^1] - E[Y_{T, 0}^1] \right) - \left( E[Y_{C, 1}^0] - E[Y_{C, 0}^0] \right) \end{align*}$$

---

# .center.pull[Two-Way Differencing]

```{r d2, echo = FALSE, warning = FALSE, fig.align = 'center', fig.width = 6.5, fig.height = 4.2}
data2 <- bind_rows(
  data %>% 
    mutate(Y2 = Y) %>% 
    mutate(state = "1. Raw Data", state2 = 1),
  data %>% 
    mutate(Y2 = Y + 1) %>% 
    mutate(state = "2. Remove Baseline Differences", state2 = 2),
  data %>% 
    mutate(Y2 = Y + 1) %>% 
    mutate(state = "3. Calculate Difference-in-Differences", state2 = 3)
)

first_two <- c("1. Raw Data", "2. Remove Baseline Differences")
options(gganimate.dev_args = list(width = 1500, height = 1100))

p <- data2 %>% 
  ggplot() + 
  geom_line(aes(x = T, y = Y, group = Unit, color = Unit), size = 1.5) + 
  geom_line(data = . %>% filter(Unit == "Control"),
            aes(x = T, y = Y2),
                color = "#E41A1C", linetype = "dashed", size = 1.5) + 
  labs(x = "Time", y = "Outcome") + 
  scale_x_continuous(breaks = c(1, 2)) + 
  scale_colour_brewer(palette = 'Set1') + 
  theme(axis.title = element_text(size = 18),
        axis.text = element_text(size = 16),
        legend.position = 'bottom',
        legend.title = element_blank(),
        legend.text = element_text(size = 16),
        plot.title = element_text(size = 25, hjust = 0.5),
        plot.background = element_blank()) + 
  geom_segment(aes(x = ifelse(state2 > 1, 0, NA)),
               xend = 0, y = 1, yend = 2, arrow = arrow(length = unit(0.1, "inches")), 
               color = "#E41A1C") + 
  geom_segment(aes(x = ifelse(state2 > 1, 0.5, NA)),
               xend = 0.5, y = 1.5, yend = 2.5, arrow = arrow(length = unit(0.1, "inches")), 
               color = "#E41A1C") + 
  geom_segment(aes(x = ifelse(state2 > 1, 1, NA)),
               xend = 1, y = 2, yend = 3, arrow = arrow(length = unit(0.1, "inches")), 
               color = "#E41A1C") + 
  geom_segment(aes(x = ifelse(state2 ==3, 1, NA)),
               xend = 1, y = 3, yend = 5, 
               color = "black") + 
  geom_segment(aes(x = ifelse(state2 ==3, 1, NA)),
               xend = 0.85, y = 5, yend = 4, 
               color = "black", linetype = "dashed") + 
  geom_segment(aes(x = ifelse(state2 ==3, 1, NA)),
               xend = 0.85, y = 3, yend = 4, 
               color = "black", linetype = "dashed") + 
  geom_label(aes(x = ifelse(state2 == 3, 0.85, NA),
                 y = ifelse(state2 == 3, 4, NA)),
             label = "Treatment \n Effect", color = "black") +
  labs(title = '\n{next_state}') + 
  transition_states(state, transition_length=c(6,6,6),state_length=c(20, 20, 20), wrap=FALSE)+
  ease_aes('sine-in-out')+
  exit_fade()+
  enter_fade()

animate(p, height = 525, width = 750)

```
---
  
# .center.pull[Regression DiD]
  
The DiD can be estimated through linear regression of the form:
  
$$\tag{1} y_{it} = \alpha + \beta_1 TREAT_i + \beta_2 POST_t + \delta (TREAT_i \cdot POST_t) + \epsilon_{it}$$
    
The coefficients from the regression estimate in (1) recover the same parameters as the double-differencing performed above:
$$\begin{align*} 
\alpha &= E[y_{it} | i = C, t = 0] = \alpha_0 + \alpha_C \\
\beta_1 &= E[y_{it} | i = T, t = 0] - E[y_{it} | i = C, t= 0] \\ 
&= (\alpha_0 + \alpha_T) - (\alpha_0 + \alpha_C) = \alpha_T - \alpha_C \\
\beta_2 &= E[y_{it} | i = C, t = 1] - E[y_{it} | i = C, t = 0] \\ 
&= (\alpha_1 + \alpha_C) - (\alpha_0 + \alpha_C) = \alpha_1 - \alpha_0 \\
\delta &= \left(E[y_{it} | i = T, t = 1] - E[y_{it} | i = T, t = 0] \right) - \\
&\hspace{.5cm} \left(E[y_{it} | i = C, t = 1] - E[y_{it} | i = C t = 0] \right) = \delta
\end{align*}$$
    
---
  
# .center.pull[Regression DiD]
<center>
$\hspace{2cm}$
  
![](https://media.giphy.com/media/Mab1lyzb70X0YiNLUj/giphy.gif)  

---
# .center.pull[Regression DiD - The Workhorse Model]

- Advantage of regression DiD - it provides both estimates of $\delta$ and standard errors for the estimates.

- $\color{blue}{\text{Angrist & Pischke (2008)}}$:
  - "It's also easy to add additional (units) or periods to the regression setup... [and] it's easy to add additional covariates."

- Two-way fixed effects estimator:
$$y_{it} = \alpha_i + \alpha_t + \delta^{DD} D_{it} + \epsilon_{it}$$
  
  - $\alpha_i$ and $\alpha_t$ are unit and time fixed effects, $D_{it}$ is the unit-time indicator for treatment.

  - $TREAT_i$ and $POST_t$ now subsumed by the fixed effects.

  - can be easily modified to include covariate matrix $X_{it}$, time trends, dynamic treatment effects estimation, etc. 
    
---
# .center.pull[Where It Goes Wrong]

- Developed literature now on the issues with TWFE DiD with "staggered treatment timing" <span style="color:blue"> (Abraham and Sun (2018), Borusyak and Jaravel (2018), Callaway and Sant'Anna (2019), Goodman-Bacon (2019), Strezhnev (2018), Athey and Imbens (2018))<span>

  - Different units receive treatment at different periods in time.

- Probably the most common use of DiD today. If done right can increase amount of cross-sectional variation.

- Without digging into the literature: 
  
  - $\delta^{DD}$ with staggered treatment timing is a *weighted average of many different treatment effects*. 
  
  - We know little about how it measures when treatment timing varies, how it compares means across groups, or why different specifications change estimates.
  
  - The weights are often negative and non-intuitive.
  
---
# .center.pull[Bias with TWFE - Goodman-Bacon (2019)]

- $\color{blue}{\text{Goodman-Bacon (2019)}}$ provides a clear graphical intuition for the bias. Assume three treatment groups - never treated units (U), early treated units (k), and later treated units (l).

```{r d3, echo = FALSE, warning = FALSE, fig.align = 'center', fig.height = 5, cache = TRUE}

data <- tibble(
  time = 0:100,
  U = seq(5, 12, length.out = 101),
  l = seq(10, 17, length.out = 101) + c(rep(0, 85), rep(15, 16)),
  k = seq(18, 25, length.out = 101) + c(rep(0, 34), rep(10, 67))
) %>% 
  pivot_longer(-time, names_to = "series", values_to = "value")

data %>% 
  ggplot(aes(x = time, y = value, group = series, color = series, shape = series)) + 
  geom_line(size = 2) + geom_point(size = 2) +
  geom_vline(xintercept = c(34, 85)) +
  labs(x = "Time", y = "Units of y") +
  scale_x_continuous(limits = c(0, 100), breaks = c(34, 85), 
                     labels = c(expression('t'['k']^'*'), expression('t'['l']^'*')), 
                     expand = c(0, 0)) + 
  annotate("text", x = 10, y = 21, label = expression('y'['it']^'k'), size = 9) +
  annotate("text", x = 50, y = 16, label = expression('y'['it']^'l'), size = 9) +
  annotate("text", x = 90, y = 14, label = expression('y'['it']^'U'), size = 9) +
  annotate('label', x = 17, y = 3, label = 'PRE(k)') +
  annotate('label', x = 60, y = 3, label = 'MID(k, l)') +
  annotate('label', x = 93, y = 3, label = 'POST(l)') +
  annotate("segment", x = 1, xend = 33, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) +
  annotate("segment", x = 33, xend = 1, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) +
  annotate("segment", x = 35, xend = 84, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) +
  annotate("segment", x = 84, xend = 35, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) + 
  annotate("segment", x = 86, xend = 99, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) +
  annotate("segment", x = 99, xend = 86, y = 2, yend = 2, color = "black", 
           arrow = arrow(length = unit(0.1, "inches"))) +
  scale_y_continuous(limits = c(0, 40), expand = c(0, 0)) +
  scale_colour_brewer(palette = 'Set1') + 
  theme(axis.ticks.x = element_blank(),
        legend.position = 'none',
        panel.grid = element_blank(),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 16),
        plot.background = element_blank())
```

---
# .center.pull[Bias with TWFE - Goodman-Bacon (2019)]

- $\color{blue}{\text{Goodman-Bacon (2019)}}$ shows that we can form four different 2x2 groups in this setting, where the effect can be estimated using the simple regression DiD in each group:

```{r d4, echo = FALSE, warning = FALSE, fig.align = 'center', fig.height = 5, cache = TRUE}
# function to make subplots
make_subplot <- function(omit, keep_dates, colors, breaks, break_expressions, series, 
                         series_x, series_y, break_names, break_loc, arrow_start, arrow_stop, title){
  
  data %>% 
    filter(series != omit & time >= keep_dates[1] & time <= keep_dates[2]) %>% 
    ggplot(aes(x = time, y = value, group = series, color = series, shape = series)) + geom_line() + geom_point() +
    geom_vline(xintercept = breaks) + 
    labs(x = "Time", y = "Units of y") +
    scale_x_continuous(limits = c(0, 105), breaks = breaks, 
                       labels = break_expressions, 
                       expand = c(0, 0)) + 
    annotate("text", x = series_x[1], y = series_y[1], label = series[1]) +
    annotate("text", x = series_x[2], y = series_y[2], label = series[2]) +
    annotate('label', x = break_loc[1], y = 5, label = break_names[1]) +
    annotate('label', x = break_loc[2], y = 5, label = break_names[2]) +
    annotate("segment", x = arrow_start[1], xend = arrow_stop[1], y = 2, yend = 2, color = "black", 
             arrow = arrow(length = unit(0.1, "inches"))) +
    annotate("segment", x = arrow_stop[1], xend = arrow_start[1], y = 2, yend = 2, color = "black", 
             arrow = arrow(length = unit(0.1, "inches"))) +
    annotate("segment", x = arrow_start[2], xend = arrow_stop[2], y = 2, yend = 2, color = "black", 
             arrow = arrow(length = unit(0.1, "inches"))) +
    annotate("segment", x = arrow_stop[2], xend = arrow_start[2], y = 2, yend = 2, color = "black", 
             arrow = arrow(length = unit(0.1, "inches"))) + 
    scale_y_continuous(limits = c(0, 40), expand = c(0, 0)) +
    scale_color_manual(values = c(colors[1], colors[2])) +  
    ggtitle(title) + 
    theme(axis.ticks.x = element_blank(),
          legend.position = 'none',
          panel.grid = element_blank(),
          plot.title = element_text(hjust = 0.5, face = "plain"),
          plot.background = element_blank()) 
}

p1 <- make_subplot(omit = "l", keep_dates = c(0, 100), colors = c('#E41A1C', '#4DAF4A'), breaks = 34, 
                   break_expressions = expression('t'['k']^'*'), 
                   series = c(expression('y'['it']^'k'), expression('y'['it']^'U')),
                   series_x = c(10, 90), series_y = c(23, 16), 
                   break_names = c('Pre(k)', 'Post(k)'), break_loc = c(17, 66), 
                   arrow_start = c(1, 35), arrow_stop = c(33, 99), 
                   title = paste('A. Early Group vs. Untreated Group'))
      
p2 <- make_subplot(omit = "k", keep_dates = c(0, 100), colors = c('#377EB8', '#4DAF4A'), breaks = 85, 
                   break_expressions = expression('t'['l']^'*'), 
                   series = c(expression('y'['it']^'l'), expression('y'['it']^'U')),
                   series_x = c(50, 90), series_y = c(18, 16), 
                   break_names = c('Pre(l)', 'Post(l)'), break_loc = c(50, 95), 
                   arrow_start = c(1, 86), arrow_stop = c(84, 99), 
                   title = paste('B. Late Group vs. Untreated Group'))

p3 <- make_subplot(omit = "U", keep_dates = c(0, 84), colors = c('#E41A1C', '#377EB8'), breaks = c(34, 85), 
                   break_expressions = c(expression('t'['k']^'*'), expression('t'['l']^'*')), 
                   series = c(expression('y'['it']^'k'), expression('y'['it']^'l')),
                   series_x = c(10, 50), series_y = c(23, 18), 
                   break_names = c('Pre(k)', 'Mid(k, l)'), break_loc = c(17, 60), 
                   arrow_start = c(1, 35), arrow_stop = c(33, 84), 
                   title = bquote(paste('C. Early Group vs. Late Group, before ', 't'['l']^'*', sep = " ")))

p4 <- make_subplot(omit = "U", keep_dates = c(34, 100), colors = c('#E41A1C', '#377EB8'), breaks = c(34, 85), 
                   break_expressions = c(expression('t'['k']^'*'), expression('t'['l']^'*')), 
                   series = c(expression('y'['it']^'k'), expression('y'['it']^'l')),
                   series_x = c(60, 50), series_y = c(36, 18), 
                   break_names = c('Mid(k, l)', 'Post(l)'), break_loc = c(60, 95), 
                   arrow_start = c(35, 86), arrow_stop = c(84, 99), 
                   title = bquote(paste('D. Late Group vs. Early Group, after ', 't'['k']^'*', sep = " ")))

# combine plots
p1 + p2 + p3 + p4 + plot_layout(nrow = 2)

```
      
---
# .center.pull[Bias with TWFE - Goodman-Bacon (2019)]

- Important Insights

  - $\delta^{DD}$ is just the weighted average of the four 2x2 treatment effects. The weights are a function of the size of the subsample, relative size of treatment and control units, and the timing of treatment in the sub sample.

  - Already-treated units act as controls even though they are treated.

  - Given the weighting function, panel length alone can change the DiD estimates substantially, even when each $\delta^{DD}$ does not change.

  - Groups treated closer to middle of panel receive higher weights than those treated earlier or later.

---
# .center.pull[Simulation Exercise]

- Can show how easily $\delta^{DD}$ goes awry up through a simulation exercise.

- Consider two sets of DiD estimates - one where the treatment occurs in one period, and one where the treatment is staggered.

- The data generating process is linear: $y_{it} = \alpha_i + \alpha_t + \delta_{it} + \epsilon_{it}$.
  - $\alpha_i, \alpha_t \sim N(0, 1)$
  - $\epsilon_{i, t} \sim N\left(0, \left(\frac{1}{2}\right)^2\right)$

- We will consider two different treatment assignment set ups for $\delta_{it}$.

---
# .center.pull[Simulation 1 - 1 Period Treatment]

- There are 40 states $s$, and 1000 units $i$ randomly drawn from the 40 states.

- Data covers years 1980 to 2010, and half the states receive "treatment" in 1995. 

- For every unit incorporated in a treated state, we pull a unit-specific treatment effect from $\mu_i \sim N(0.3, (1/5)^2)$.

- Treatment effects here are trend breaks rather than unit shifts: the accumulated treatment effect $\delta_{it}$ is $\mu_i \times (year - 1995 + 1)$ for years after 1995. 

- We then estimate the average treatment effect as $\hat{\delta}$ from:

  $$y_{it} = \hat{\alpha_i} + \hat{\alpha_t} + \hat{\delta} D_{it}$$

- Simulate this data 1,000 and plot the distribution of estimates $\hat{\delta}$ and the true effect (red line).
      
---
# .center.pull[Simulation 1 - 1 Period Treatment]
    
```{r d5, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
# Make Data  ---------------------------------------------
# loop function for one-time DiD shock
DID_onetime <- function(...) {
  
  # Fixed Effects ------------------------------------------------
  # unit fixed effects
  unit <- tibble(
    unit = 1:1000, 
    unit_fe = rnorm(1000, 0, 1),
    # generate state
    state = sample(1:40, 1000, replace = TRUE),
    # generate treatment effect
    mu = rnorm(1000, 0.3, 0.2))
  
  # year fixed effects 
  year <- tibble(
    year = 1980:2010,
    year_fe = rnorm(31, 0, 1))
  
  # Trend Break -------------------------------------------------------------
  # Put the states into treatment groups
  treat_taus <- tibble(
    # sample the states randomly
    state = sample(1:40, 40, replace = FALSE),
    # place the randomly sampled states into treatment and control states
    treated_unit = sample(c(rep(1, 20), rep(0, 20)), 40, replace = FALSE))
  
  # make main dataset
  # full interaction of unit X year 
  data <- expand_grid(unit = 1:1000, year = 1980:2010) %>% 
    left_join(., unit) %>% 
    left_join(., year) %>% 
    left_join(., treat_taus) %>% 
    # make error term and get treatment indicators and treatment effects
    mutate(error = rnorm(31000, 0, 0.5),
           treat = ifelse(year >= 1995 & treated_unit == 1, 1, 0),
           tau = ifelse(treat == 1, mu, 0)) %>% 
    # calculate cumulative treatment effects
    group_by(unit) %>% 
    mutate(tau_cum = cumsum(tau)) %>% 
    ungroup() %>% 
    # calculate the dep variable
    mutate(dep_var = unit_fe + year_fe + tau_cum + error)
  
  # run the DID and get the treatment effect estimates
  broom::tidy(felm(dep_var ~ treat | unit + year | 0 | state, data = data,
                   exactDOF = TRUE, cmethod = "reghdfe"))
}

# estimate 1000 times 
# set seed
set.seed(2140851)
DID_one_data <- map_dfr(1:1000, DID_onetime)

# plot DID estimates
DID_one_data %>% 
  ggplot(aes(x = estimate)) + geom_density(fill = "gray", alpha = 1/2) + 
  geom_vline(xintercept = 8.5*.3, color = "red", size = 2) + 
  labs(x = "Estimate Size", y = "Density") + 
  theme(axis.title = element_text(size = 14))

```
---
# .center.pull[Simulation 1 - 1 Period Treatment]
        
<center>
$\hspace{2cm}$
![](https://media.giphy.com/media/drwxYI2fxqQGqRZ9Pe/giphy.gif)

---
# .center.pull[Simulation 2 - Staggered Treatment]
        
- Run similar analysis with staggered treatment. 
      
- The 40 states are randomly assigned into four treatment cohorts of size 250 depending on year of treatment assignment (1986, 1992, 1998, and 2004)
      
- DGP is identical, except that now $\delta_{it}$ is equal to $\mu_i \times (year - \tau_g + 1)$ where $\tau_g$ is the treatment assignment year. 
      
- Estimate the treatment effect using TWFE and compare to the analytically derived true $\delta$ (red line).
      
---
# .center.pull[Simulation 2 - Staggered Treatment]
        
```{r d6, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
      
## estimate DID model 2 - 250 firms are treated every period, with the treatment effect still = 0.3 on average
# loop function for one-time DiD shock
DID_multiple <- function(...) {
  
  # Fixed Effects ------------------------------------------------
  # unit fixed effects
  unit <- tibble(
    unit = 1:1000, 
    unit_fe = rnorm(1000, 0, 1),
    # generate state
    state = sample(1:40, 1000, replace = TRUE),
    # generate treatment effect
    mu = rnorm(1000, 0.3, 0.2))
  
  # year fixed effects 
  year <- tibble(
    year = 1980:2010,
    year_fe = rnorm(31, 0, 1))
  
  # Trend Break -------------------------------------------------------------
  # Put the states into treatment groups
  treat_taus <- tibble(
    # sample the states randomly
    state = sample(1:40, 40, replace = FALSE),
    # place the randomly sampled states into five treatment groups G_g
    cohort_year = sort(rep(c(1986, 1992, 1998, 2004), 10)))
  
  # make main dataset
  # full interaction of unit X year 
  data <- expand_grid(unit = 1:1000, year = 1980:2010) %>% 
    left_join(., unit) %>% 
    left_join(., year) %>% 
    left_join(., treat_taus) %>% 
    # make error term and get treatment indicators and treatment effects
    mutate(error = rnorm(31000, 0, 0.5),
           treat = ifelse(year >= cohort_year, 1, 0),
           tau = ifelse(treat == 1, mu, 0)) %>% 
    # calculate cumulative treatment effects
    group_by(unit) %>% 
    mutate(tau_cum = cumsum(tau)) %>% 
    ungroup() %>% 
    # calculate the dep variable
    mutate(dep_var = unit_fe + year_fe + tau_cum + error)
  
  # run the DID and get the treatment effect estimates
  broom::tidy(felm(dep_var ~ treat | unit + year | 0 | state, data = data,
                   exactDOF = TRUE, cmethod = "reghdfe"))
}

# set seed
set.seed(2140851)
DID_multiple <- map_dfr(1:1000, DID_multiple)

# plot DID estimates
DID_multiple %>% 
  ggplot(aes(x = estimate)) + geom_density(fill = "gray", alpha = 1/2) + 
  geom_vline(xintercept = 8.5*.3, color = "red", size = 2) + 
  labs(x = "Estimate Size", y = "Density") + 
  theme(axis.title = element_text(size = 14))
    
```
---
# .center.pull[Simulation 2 - Staggered Treatment]
  <center>
  $\hspace{2cm}$        
  ![](https://media.giphy.com/media/4cuyucPeVWbNS/giphy.gif)
---
# .center.pull[Simulation 2 - Staggered Treatment]
        
- Main problem - we use prior treated units as controls. 
      
- When the treatment effect is "dynamic", i.e. takes more than one period to be incorporated into your dependent variable, you are *subtracting* the treatment effects from prior treated units from the estimate of future control units. 
      
- This biases your estimates towards zero when all the treatment effects are the same. 
      
---
# .center.pull[Another Simulation]
        
- Can we actually get estimates for $\delta$ that are of the *wrong sign*? Yes, if treatment effects for early treated units are larger (in absolute magnitude) than the treatment effects on later treated units. 
      
- Here firms are randomly assigned to one of 50 states. The 50 states are randomly assigned into one of 5 treatment groups $G_g$ based on treatment being initiated in 1985, 1991, 1997, 2003, and 2009. 
      
- All treated firms incorporated in a state in treatment group $G_g$ receive a treatment effect $\delta_i \sim N(\delta_g, .2^2)$.
      
- The treatment effect is cumulative or dynamic - $\delta_{it} = \delta_i \times (year - G_g)$.
---
# .center.pull[Another Simulation]
        
- The average treatment effect multiple decreases over time:
        
$\hspace{2cm}$
        
```{r d7, message = FALSE, error = FALSE, echo = FALSE, cache = TRUE, results = 'asis'}
treats <- tibble(
  "$G_g$" = c(1985, 1991, 1997, 2003, 2009),
  "$\\delta_g$" =  c(.5, .4, .3, .2, .1)
)
      
kable(treats, format = "html", align = 'c', 
      booktabs = T, caption = "Treatment Effect Averages") %>% 
    kable_styling(position = "center", full_width = T)
```
      
---
# .center.pull[Another Simulation]
        
- First let's look at the distribution of $\delta^{DD}$ using TWFE estimation with this simulated sample:

```{r d8, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.height = 6, fig.width = 10}
# set seed
set.seed(2140851)

runreg <- function(i){
    # Fixed Effects ------------------------------------------------
  # unit fixed effects
  unit <- tibble(
    unit = 1:1000, 
    unit_fe = rnorm(1000, 0, 1),
    # generate state
    state = sample(1:50, 1000, replace = TRUE))
  
  # year fixed effects 
  year <- tibble(
    year = 1980:2015,
    year_fe = rnorm(36, 0, 1))
  
  # Trend Break -------------------------------------------------------------
  # Put the states into treatment groups
  treat_taus <- tibble(
    # sample the states randomly
    state = sample(1:50, 50, replace = FALSE),
    # place the randomly sampled states into five treatment groups G_g
    cohort_year = sort(rep(c(1985, 1991, 1997, 2003, 2009), 10)),
    # assign them a mean treatment effect from 0.5 to 0.1
    mu = sort(rep(c(.5, .4, .3, .2, .1), 10), decreasing = TRUE))
  
  # make main dataset
  # full interaction of unit X year 
  data <- expand_grid(unit = 1:1000, year = 1980:2015) %>% 
    left_join(., unit) %>% 
    left_join(., year)
  
  # bring in the treatment indicators and values
  get_treat <- function(u) {
    # get the state for the unit
    st <- unit %>% filter(unit == u) %>% pull(state)
    
    # find the treatment year for the state
    treat_yr <- treat_taus %>% filter(state == st) %>% pull(cohort_year)
    
    # treatment effect tau_g
    mu <- treat_taus %>% filter(state == st) %>% pull(mu)
    
    # Make a data set with the results 
    tibble(unit = rep(u, 36), 
           year = 1980:2015,
           # get a treatment cohort indicator
           # make treatment indicator
           treat = ifelse(year < treat_yr, 0, 1),
           # get the treatment effect \tau_i for post-treatment years
           cohort_year = treat_yr,
           static_tau = rep(rnorm(1, mu, .2), 36),
           tau = ifelse(year < treat_yr, 0, static_tau),
           # cumulate the effect
           tau_cum = cumsum(tau))
    }
  
  # call the function over our 1000 firms
  treatments <- map_dfr(1:1000, get_treat)
  
  # merge in the treatment effect data
  data <- left_join(data, treatments) %>% 
    # simulate error and generate the dependent variable
    mutate(error = rnorm(36000, 0, 0.5),
           dep_var = unit_fe + year_fe + tau_cum + error)
  
   broom::tidy(felm(dep_var ~ treat | unit + year | 0 | state, data = data,
                   exactDOF = TRUE, cmethod = "reghdfe"))
}

simdata <- map_dfr(1:300, runreg)

simdata %>% 
  ggplot(aes(x = estimate)) + geom_density(fill = "gray", alpha = 1/2) + 
  geom_vline(xintercept = 0, color = "red", size = 2) + 
  labs(x = "Estimate Size", y = "Density") + 
  theme(axis.title = element_text(size = 14))
```

---
# .center.pull[Goodman-Bacon Decomposition]

```{r d9, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
# unit fixed effects
unit <- tibble(
  unit = 1:1000, 
  unit_fe = rnorm(1000, 0, 1),
  # generate state
  state = sample(1:50, 1000, replace = TRUE))

# year fixed effects 
year <- tibble(
  year = 1980:2015,
  year_fe = rnorm(36, 0, 1))

# Trend Break -------------------------------------------------------------
# Put the states into treatment groups
treat_taus <- tibble(
  # sample the states randomly
  state = sample(1:50, 50, replace = FALSE),
  # place the randomly sampled states into five treatment groups G_g
  cohort_year = sort(rep(c(1985, 1991, 1997, 2003, 2009), 10)),
  # assign them a mean treatment effect from 0.5 to 0.1
  mu = sort(rep(c(.5, .4, .3, .2, .1), 10), decreasing = TRUE))

# make main dataset
# full interaction of unit X year 
data <- expand_grid(unit = 1:1000, year = 1980:2015) %>% 
  left_join(., unit) %>% 
  left_join(., year)

# bring in the treatment indicators and values
get_treat <- function(u) {
  # get the state for the unit
  st <- unit %>% filter(unit == u) %>% pull(state)
  
  # find the treatment year for the state
  treat_yr <- treat_taus %>% filter(state == st) %>% pull(cohort_year)
  
  # treatment effect tau_g
  mu <- treat_taus %>% filter(state == st) %>% pull(mu)
  
  # Make a data set with the results 
  tibble(unit = rep(u, 36), 
         year = 1980:2015,
         # get a treatment cohort indicator
         # make treatment indicator
         treat = ifelse(year < treat_yr, 0, 1),
         # get the treatment effect \tau_i for post-treatment years
         cohort_year = treat_yr,
         static_tau = rep(rnorm(1, mu, .2), 36),
         tau = ifelse(year < treat_yr, 0, static_tau),
         # cumulate the effect
         tau_cum = cumsum(tau))
  }

# call the function over our 1000 firms
treatments <- map_dfr(1:1000, get_treat)

# merge in the treatment effect data
data <- left_join(data, treatments) %>% 
  # simulate error and generate the dependent variable
  mutate(error = rnorm(36000, 0, 0.5),
         dep_var = unit_fe + year_fe + tau_cum + error)

# calculate the bacon decomposition without covariates
bacon_out <- bacon(dep_var ~ treat,
                   data = data,
                   id_var = "unit",
                   time_var = "year")

bacon_out %>% 
  ggplot(aes(x = weight, y = estimate, shape = factor(type), color = factor(type))) +
  geom_point(size = 3) +
  geom_hline(yintercept = 0) +
  scale_colour_brewer(palette = 'Set1') + 
  labs(x = "Weight", y = "Estimate") + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 16))

```

---
# .center.pull[Callaway & Sant'Anna]

- Inverse propensity weighted long-difference in cohort-specific average treatment effects between treated and untreated units for a given treatment cohort. 

$$\begin{equation} ATT(g, t) = \mathbb{E} \left[\left( \frac{G_g}{\mathbb{E}[G_g]} - \frac{\frac{p_g(X)C}{1 - p_g(X)}}{\mathbb{E}\left[\frac{p_g(X)C}{1 - p_g(X)} \right]} \right) \left(Y_t - T_{g - 1}\right)\right] \end{equation}$$
  
  
  - Without covariates, as in the simulated example here, it calculates the simple long difference between all treated units $i$ in relative year $k$ with all potential control units that have not yet been treated by year $k$.

---
# .center.pull[Callaway & Sant'Anna]
  
```{r d10, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}

# create a lead/lag indicators
data <- data %>% 
  # variable with relative year from treatment
  mutate(rel_year = year - cohort_year) %>% 
  # drop observations after 2008 bc all treated 
  filter(year <= 2008) %>% 
  dplyr::arrange(cohort_year, unit, year)

# first get percentage contribution to each lead/lag indicator by treatment cohort for weights
# we will need this for the Abraham/Sun method, as well as the true treatment indicator
# calculate weights
weights <- data %>% 
  mutate(rel_year = year - cohort_year) %>% 
  # drop covariates for 2009 adopters
  filter(cohort_year != 2009) %>% 
  group_by(cohort_year, rel_year) %>% 
  count %>% 
  ungroup() %>% 
  group_by(rel_year) %>% 
  mutate(total = sum(n),
         perc = n / total) %>% 
  # keep just the variables we need
  select(rel_year, cohort_year, perc) %>% 
  ungroup() %>% 
  rowwise() %>% 
  # add variable equal to coefficient from regression
  mutate(term = paste("cohort_year_", cohort_year, "_", rel_year + 29, sep = "")) %>% 
  ungroup()

# make a dataset with the theoretical values to merge in
true_effect <- weights %>% 
  # add in the multiples
  mutate(
    multiple = case_when(
      rel_year < 0 ~ 0,
      rel_year >= 0 ~ rel_year + 1),
    # add in the tau_g values 
    tau_g = case_when(
      cohort_year == 1985 ~ .5,
      cohort_year == 1991 ~ .4,
      cohort_year == 1997 ~ .3,
      cohort_year == 2003 ~ .2),
    # multiply the two 
    effect = multiple*tau_g) %>% 
  #collapse by  time period 
  group_by(rel_year) %>% 
  summarize(true_tau = weighted.mean(effect, w = perc)) %>% 
  # make the time variable for merging
  mutate(t = rel_year)

# run the CS algorithm
CS_out <- att_gt("dep_var", data = data,
                 first.treat.name="cohort_year",
                 idname="unit", tname="year", aggte = T,
                 clustervars = "state",
                 bstrap=T, cband=T,
                 maxe = 6,
                 mine = -4,
                 nevertreated = F,
                 printdetails = F)

# plot
tibble(
  t = -5:5,
  estimate = CS_out$aggte$dynamic.att.e,
  se = CS_out$aggte$dynamic.se.e,
  conf.low = estimate - 1.96*se,
  conf.high = estimate + 1.96*se,) %>% 
  left_join(true_effect) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>%
  # plot
  ggplot(aes(x = t, y = estimate)) + 
  geom_line(aes(x = t, y = true_tau, color = "True Effect"), size = 1.5, linetype = "dashed") + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  #geom_point(aes(color = "Estimated Effect")) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "Estimated Effect"), show.legend = FALSE) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -5:5) + 
  labs(x = "Relative Time", y = "Estimate") +
  scale_color_brewer(palette = 'Set1') + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 16)) 

```

---
# .center.pull[Abraham and Sun]
  
- A relatively straightforward extension of the standard event-study TWFE model:
  
  $$y_{it} = \alpha_i + \alpha_t + \sum_e \sum_{l \neq -1} \delta_{el}(1\{E_i = e\} \cdot D_{it}^l) + \epsilon_{it}$$
  
- You saturate the relative time indicators (i.e. t = -2, -1, ...) with indicators for the treatment initiation year group, and aggregate to overall aggregate relative time indicators by cohort size.

- In the case of no covariates, this gives you the same estimate as Callaway & Sant'Anna if you *fully saturate* the model with time indicators (leaving only two relative year identifiers missing).

- The authors don't claim that it can be used with covariates, but it seemingly follows if we think it is okay with normal TWFE DiD. 

---
# .center.pull[Abraham and Sun]
```{r d11, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}

## Make cohort-relative time dummies
# relative year dummies
rel_year <- data %>% select(rel_year) %>% 
  dummy_cols %>% select(-1) %>% 
  set_colnames(as.numeric(str_remove(colnames(.), "rel_year_")) + 29) %>% 
  as.data.frame

# cohort dummies
cohorts <- data %>% select(cohort_year) %>% 
  dummy_cols %>% select(-1) %>% 
  as.data.frame

# combine matrix functions
combine_mat <- function(i) {
  cohorts[, i] * rel_year %>% 
    set_colnames(paste(colnames(cohorts)[i], colnames(rel_year), sep = "_"))
}

# combine dummies and merge into our data
dummies <- map_dfc(1:4, combine_mat)
data <- data %>% bind_cols(dummies)

# put the covariates into a vector form
covs <- paste("cohort_year_", rep(c(1985, 1991, 1997, 2003), 51), "_", c(-28:-2, 0:23) + 29, sep = "")

# estimate the saturated model
fit <- felm(as.formula(paste("dep_var ~ ", paste(covs, collapse = "+"), "| unit + year | 0 | state")), 
            data = data, exactDOF = TRUE)

# rerun without the NA covariates because glmt won't run otherwise
# new set of covariates without the na
covs <- broom::tidy(fit) %>% filter(!is.na(estimate)) %>% pull(term)
fit <- felm(as.formula(paste("dep_var ~ ", paste(covs, collapse = "+"), "| unit + year | 0 | state")), 
            data = data, exactDOF = TRUE)

# get the coefficients and make a dataset for plotting
coefs <- fit$coefficients %>%
  # add in coefficient name to tibble
  as_tibble(rownames = "term") %>% 
  # bring in weights
  left_join(., weights)

# get the relevant coefficients and weights into a string to get the linear combination
get_lincom <- function(ll) {
  # get just the coefficients for a specific lead lag
  cf2 <- coefs %>% filter(rel_year == ll)
  # paste the function that goes into the linear combination function
  F <- paste(paste(cf2$perc, cf2$term, sep = " * ", collapse = " + "), " = 0")
  # take linear combination and put into a data frame
  broom::tidy(
    confint(glht(fit, linfct = F)),
    conf.int = TRUE
  ) %>% mutate(rel_year = ll)
}

# run over all lead/lags
AS_plot <- map_df(c(-5:-2, 0:5), get_lincom) %>% 
  # add time variable
  mutate(t = c(-5:-2, 0:5))

#Plot the results
AS_plot %>% 
  select(t, estimate, conf.low, conf.high) %>% 
  # add in data for year -1
  bind_rows(tibble(t = -1, estimate = 0, 
                   conf.low = 0, conf.high = 0
  )) %>% 
  left_join(true_effect) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>%
  # plot
  ggplot(aes(x = t, y = estimate)) + 
  geom_line(aes(x = t, y = true_tau, color = "True Effect"), size = 1.5, linetype = "dashed") + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  #geom_point(aes(color = "Estimated Effect")) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "Estimated Effect"), show.legend = FALSE) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -5:5) + 
  labs(x = "Relative Time", y = "Estimate") +
  scale_color_brewer(palette = 'Set1') + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 16))

```

---
# .center.pull[Cengiz et al. (2019)]
  
- Similar to the standard TWFE DiD, but we ensure that no previously treated units enter as controls by trimming the sample.

- For each treatment cohort $G_g$, get all treated units, and all units that are not treated by year $g + k$ where $g$ is the treatment year and $k$ is the outer most relative year that you want to test (e.g. if you do an event study plot from -5 to 5, $k$ would equal 5).

- Keep only observations within years $g - k$ and $g + k$ for each cohort-specific dataset, and then stack them in relative time. 

- Run the same TWFE estimates as in standard DiD, but include interactions for the cohort-specific dataset with all of the fixed effects, controls, and clusters.

---
# .center.pull[Cengiz et al. (2019)]
```{r d12, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}

# get the cohort years
obs <- data %>% 
  filter(cohort_year != 2009) %>% 
  pull(cohort_year) %>% 
  unique()

# make fomula to run within our FE specification
# get the lead lags in one set of covariates
leadlags <- c("lag_5", "lag_4", "lag_3", "lag_2", "date_0",
              "lead_1", "lead_2", "lead_3", "lead_4", "lead_5")

# add in lead lags
data <- data %>% 
  # variable with relative year from treatment
  mutate(rel_year = year - cohort_year,
         # make lead lag variable with string
         leadlag = case_when(
           rel_year < -5 ~ "Pre",
           rel_year == -5 ~ "lag_5",
           rel_year == -4 ~ "lag_4",
           rel_year == -3 ~ "lag_3",
           rel_year == -2 ~ "lag_2",
           rel_year == -1 ~ "lag_1",
           rel_year == 0 ~ "date_0",
           rel_year == 1 ~ "lead_1",
           rel_year == 2 ~ "lead_2",
           rel_year == 3 ~ "lead_3",
           rel_year == 4 ~ "lead_4",
           rel_year == 5 ~ "lead_5",
           rel_year > 5 ~ "Post"),
         # make a second one to turn into dummies
         leadlag2 = leadlag) %>% 
  # turn them into indicator variables
  mutate(val = 1) %>% 
  pivot_wider(names_from = "leadlag2", values_from = "val", values_fill = list(val = 0))

# Make the estimating equation
formula_cldz2 <- as.formula(paste("dep_var ~", paste(leadlags, collapse = " + "), 
                                  "| factor(unit):factor(df) + factor(year):factor(df) | 0 | state_df"))

# make formula to create the dataset
getdata <- function(i) {
  
  #keep what we need
  data %>% 
    # keep treated units and all units not treated within -5 to 5
    filter(cohort_year == i | cohort_year > i + 5) %>% 
    # keep just year -5 to 5
    filter(year >= i - 5 & year <= i + 5) %>%
    # create an indicator for the dataset
    mutate(df = i) %>% 
    # replace lead/lag indicators if not in the treatment cohort
    mutate(lag_5 = ifelse(cohort_year != df, 0, lag_5),
           lag_4 = ifelse(cohort_year != df, 0, lag_4),     
           lag_3 = ifelse(cohort_year != df, 0, lag_3),
           lag_2 = ifelse(cohort_year != df, 0, lag_2),
           date_0 = ifelse(cohort_year != df, 0, date_0),
           lead_1 = ifelse(cohort_year != df, 0, lead_1),
           lead_2 = ifelse(cohort_year != df, 0, lead_2),
           lead_3 = ifelse(cohort_year != df, 0, lead_3),
           lead_4 = ifelse(cohort_year != df, 0, lead_4),
           lead_5 = ifelse(cohort_year != df, 0, lead_5))
}

# get data stacked
stacked_data <- map_df(obs, getdata) %>% mutate(state_df = paste(state, df))

# estimate the model on our stacked data
stacked_data %>% 
  # fit the model
  do(fit = felm(formula_cldz2, data = ., exactDOF = TRUE, cmethod = "reghdfe")) %>% 
  broom::tidy(fit, conf.int = TRUE) %>% 
  # keep just the variables we are going to plot
  filter(term %in% leadlags) %>% 
  # make a relative time variable
  mutate(t = c(-5:-2, 0:5)) %>% 
  select(t, estimate, conf.low, conf.high) %>% 
  # add in data for year -1
  bind_rows(tibble(t = -1, estimate = 0, 
                   conf.low = 0, conf.high = 0
  )) %>% 
  left_join(true_effect) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>%
  # plot
  ggplot(aes(x = t, y = estimate)) + 
  geom_line(aes(x = t, y = true_tau, color = "True Effect"), size = 1.5, linetype = "dashed") + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  #geom_point(aes(color = "Estimated Effect")) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "Estimated Effect"), show.legend = FALSE) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -5:5) + 
  labs(x = "Relative Time", y = "Estimate") +
  scale_color_brewer(palette = 'Set1') + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.title = element_text(size = 18),
        axis.text = element_text(size = 16))
```
---
# .center.pull[Model Comparison]
- In the stylized example all the models work. How do they differ?
  
- Callaway & Sant'Anna 
  
  - Can be *very* flexible in determining which control units to consider.
  - Has a more flexible functional form as well (IPW instead of OLS).
  - IPW can run into issues with p-scores near 0 or 1. But just bc OLS runs doesn't mean it's right!

- Abraham & Sun 
  
  - Very similar to regular TWFE OLS and hence easy to explain. 
  - Control units are all units not treated within the data sample. If most of your units are treated by the end (or all), this can make control units very non-representative and restricted. 
  
- Cengiz et al. 
  
  - Also fairly close to regular DiD. 
  - Can modify this framework to allow different forms of control units as well.
  - Not theoretically derived.
  
---
# .center.pull[Application - Medical Marijuana Laws and Opioid Overdose Deaths]

- $\color{blue}{\text{Bachhuber et al. 2014}}$ found, using a staggered DiD, that states with medical cannabis laws experienced a slower increase in opioid overdose mortality from 1999-2010.

- $\color{blue}{\text{Shover et al.  2020}}$ extend the data sample from 2010 to 2017, a period during which 32 extra states passed MML laws.

- Not only do the results go away, but the sign flips; MML laws are associated with *higher* opioid overdose mortality rates.

- Authors don't call it difference-in-differences, but it uses TWFE with a binary indicator variable (thus is effectively DiD).

---
# .center.pull[Replication]
```{r d13, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
data <- read_csv("/Users/Andrew/Box Sync/Website/andrew-baker/content/post/pnas.csv")

# make formula to run regression 
model_formula <- as.formula("ln_age_mort_rate ~ Medical_Cannabis_Law + rxdmp_original + 
               rxid_original + pmlaw_original + unemployment | state + Year | 0 | 0")

# run the regression separately for 1999-2010 and full data thru 2017
# bind two different datasets, one filtered
bind_rows(
  data %>% mutate(df = "1999-2017"),
  data %>% filter(Year <= 2010) %>% mutate(df = "1999-2010")
) %>% 
  # run the models by dataset
  group_by(df) %>% 
  do(fit = felm(model_formula, data = ., exactDOF = TRUE, cmethod = "reghdfe")) %>% 
  broom::tidy(fit, conf.int = TRUE) %>% 
  # keep just the variables we are going to plot
  filter(term == "Medical_Cannabis_Law") %>%
  # keep just the variables we need
  select(df, estimate, conf.low, conf.high) %>% 
  # column for replication
  mutate(type = "Replication") %>% 
  # bring in published estimates
  bind_rows(tibble(
    df = c("1999-2017", "1999-2010"),
    estimate = c(.227, -.211), 
    conf.low = c(.02, -.357),
    conf.high = c(.476, -.03),
    type = rep("As Published", 2)
  )) %>% 
  # plot differences
  ggplot() + 
  geom_pointrange(aes(x = type, y = estimate, ymin = conf.low, ymax = conf.high,
                      group = type, color = type)) + 
  geom_hline(yintercept = 0, linetype = 'dashed') + 
  theme(legend.title = element_blank(),
        axis.title.y = element_blank()) + 
  theme_bw() + 
  labs(y = "Estimate", x = "") + 
  scale_colour_brewer(palette = 'Set1') + 
  theme(legend.position = 'bottom',
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 17),
        strip.text = element_text(size = 18),
        strip.background = element_rect(fill = "grey", color = "black", size = 1),
        legend.title = element_blank()) + 
  coord_flip() +
  facet_wrap(~df)

```

---
# .center.pull[Event Study Estimates]
  
- Little evidence covariates matter here, so estimate standard DiD with no controls over the two periods:
  
  $$y_{it} = \alpha_i + \alpha_t + \sum_{k = Pre, Post} \delta_k + \sum_{-3}^3 \delta_k + \epsilon_{it}$$
```{r d14, echo = FALSE, warning = FALSE, message = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10, fig.height = 5}
# get number of states that adopted laws in a given year
adopt_years <- data %>% 
  group_by(state) %>% 
  mutate(adopt = ifelse(Medical_Cannabis_Law > 0 & lag(Medical_Cannabis_Law) == 0, 1, 0)) %>% 
  filter(adopt == 1) %>% 
  select(state, Year) %>% 
  rename(adopt_year = Year)

# merge in adopt years to data
data <- data %>% left_join(., adopt_years)

# first do event study 
# get a data_2010 dataset that doesn't have any adoptions after 2010
data_2010 <- data %>% 
  filter(Year <= 2010) %>% 
  # drop adopt_year if after 2010 %>% 
  mutate(adopt_year = ifelse(adopt_year > 2010, NA, adopt_year))

# for both datasets create a lead/lag indicators
data <- data %>% 
  # variable with relative year
  mutate(rel_year = Year - adopt_year,
         leadlag = case_when(
           rel_year < -3 ~ "Pre",
           rel_year == -3 ~ "lag_3",
           rel_year == -2 ~ "lag_2",
           rel_year == -1 ~ "lag_1",
           rel_year == 0 ~ "date_0",
           rel_year == 1 ~ "lead_1",
           rel_year == 2 ~ "lead_2",
           rel_year == 3 ~ "lead_3",
           rel_year > 3 ~ "Post",
           is.na(rel_year) ~ "Missing",
         ),
         leadlag2 = leadlag) %>% 
  # turn them into indicator variables
  mutate(val = 1) %>% 
  pivot_wider(names_from = "leadlag2", values_from = "val", values_fill = list(val = 0))

data_2010 <- data_2010 %>% 
  # variable with relative year
  mutate(rel_year = Year - adopt_year,
         leadlag = case_when(
           rel_year < -3 ~ "Pre",
           rel_year == -3 ~ "lag_3",
           rel_year == -2 ~ "lag_2",
           rel_year == -1 ~ "lag_1",
           rel_year == 0 ~ "date_0",
           rel_year == 1 ~ "lead_1",
           rel_year == 2 ~ "lead_2",
           rel_year == 3 ~ "lead_3",
           rel_year > 3 ~ "Post",
           is.na(rel_year) ~ "Missing",
         ),
         leadlag2 = leadlag) %>% 
  # turn them into indicator variables
  mutate(val = 1) %>% 
  pivot_wider(names_from = "leadlag2", values_from = "val", values_fill = list(val = 0))

# plot the two sets of DiD estimates
# all covariates for lead/lags
covariates <- c("Pre", "lag_3", "lag_2", "date_0", "lead_1", "lead_2", "lead_3", "Post")

# isolate the variables that we want to plot
covariates_interest <- c("lag_3", "lag_2", "date_0", "lead_1", "lead_2", "lead_3")

# put in the model formula
model_formula_es <- as.formula(
  paste("ln_age_mort_rate ~ ", paste(covariates, collapse = " + "),
        "| state + Year | 0 | 0 ")
)

# combine datasets and run two models for pre and post 
bind_rows(data %>% mutate(df = "1999-2017"), data_2010 %>% mutate(df = "1999-2010")) %>% 
  # run the models by dataset
  group_by(df) %>% 
  do(fit = felm(model_formula_es, data = ., exactDOF = TRUE, cmethod = "reghdfe")) %>% 
  broom::tidy(fit, conf.int = TRUE) %>% 
  # keep just the variables we are going to plot
  filter(term %in% covariates_interest) %>% 
  # reformat d data
  group_by(df) %>% 
  mutate(t = c(-3:-2, 0:3)) %>% 
  select(df, t, estimate, conf.low, conf.high) %>% 
  # add in data for year -1
  bind_rows(tibble(
    df = c("1999-2017", "1999-2010"), t = rep(-1, 2), estimate = rep(0, 2), 
    conf.low = rep(0, 2), conf.high = rep(0,2)
  )) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>% 
  # plot
  ggplot(aes(x = t, y = estimate)) + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "#E41A1C"), 
                  show.legend = FALSE, size = 1) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -5:5) + 
  theme(axis.title.x = element_blank(),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 17),
        strip.text = element_text(size = 18)) + 
  facet_wrap(~df, scales = "free_y")

```

---
# .center.pull[Event Study Estimates]
  
- So we can verify that in the first sample (1999 - 2010), there appears to be a negative effect of law introduction, while in the full sample (1999 - 2017), there is a positive effect. 

- *But* there appears to be evidence of pre-trends in the full sample.

- In addition, by the end of the sample the number of firms adopting MMLs is quite large. 

- If there are dynamic treatment effects, then these estimates could be biased from using many prior treated states as controls.

---
# .center.pull[Bacon-Goodman Decomposition]
```{r d15, echo = FALSE, warning = FALSE, message = FALSE, error = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}

# first to the goodman-bacon decomposition
# need to make the panel balanced
# drop North Dakota - missing some observations and don't know what would have happened with the other laws
data_no_ND <- data %>% filter(state != "North Dakota")

# make function to get merge data with interpolated data
fill_missing <- function(var) {
  # use matrix completion to fill in missing values of mortality rate
  variable_matrix <- data_no_ND %>% 
    # format wide and save as matrix
    select(state, Year, {{var}}) %>% 
    pivot_wider(names_from = "state", values_from = {{var}}) %>% 
    select(-Year) %>% 
    as.matrix() %>% t()
  
  # get mask matrix which is 1 for non missing and 0 for missing
  mask <- matrix(1, nrow = nrow(variable_matrix), ncol = ncol(variable_matrix))
  mask[which(is.na(variable_matrix))] <- 0
  
  # replace NA with 0 in the raw data so MCPanel runs
  variable_matrix[is.na(variable_matrix)] <- 0 
  
  # run the matrix completion algorithm
  mc_data <- mcnnm_cv(variable_matrix, mask, to_estimate_u = 0, to_estimate_v = 0)$L
  
  # fill in the missing entries from the raw data with the estimates
  variable_matrix[which(mask == 0)] <- mc_data[which(mask == 0)]
  
  # reformat as long for merging
  variable_matrix %>% 
    t() %>% 
    as_tibble() %>% 
    mutate(Year = 1999:2017) %>% 
    pivot_longer(-Year, names_to = "state", values_to = paste({{var}}, 2, sep = ""))
}

# make the merge matrices
merge_mort <- fill_missing("ln_age_mort_rate")
merge_unemp <- fill_missing("unemployment")

# merge the data back in
data_no_ND <- data_no_ND %>% 
  left_join(., merge_mort) %>% left_join(merge_unemp) %>% 
  # make a new treatment indicator that is just 1 or 0
  mutate(TREAT = ifelse(Medical_Cannabis_Law > 0, 1, 0))

# calculate the bacon decomposition without covariates
bacon_out <- bacon(ln_age_mort_rate2 ~ TREAT,
                   data = data_no_ND,
                   id_var = "state",
                   time_var = "Year")

# plot
bacon_out %>% 
  ggplot(aes(x = weight, y = estimate, shape = factor(type), color = factor(type))) +
  geom_point(size = 4) +
  geom_hline(yintercept = 0) +
  scale_colour_brewer(palette = 'Set1') + 
  labs(x = "Weight", y = "Estimate") + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 15))
```

---
# .center.pull[Bacon-Goodman Decomposition]
  
- The unweighted average of the 2x2 treatment effects are negative for the earlier vs. later treated (unbiased), while positive for the later vs. earlier treated (biased). 

- The effect is also positive for the treated vs. untreated units, but there are not many untreated states (i.e. states without medical cannabis laws).

```{r d16, echo = FALSE, warning = FALSE, message = FALSE, error = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
bacon_out %>% 
  group_by(type) %>% 
  summarize(Avg_Estimate = mean(estimate),
            Number_Comparisons = n(),
            Total_Weight = sum(weight)) %>% 
  kable(format = "html", booktabs = T, digits = 2, align = 'c',
        col.names = c("Type", "Average Estimate", "Number of 2x2 Comparisons", "Total Weight")) %>% 
  kable_styling(bootstrap_options = c("striped", "hover")) 


```

---
# .center.pull[Callaway & Sant'Anna]
  
```{r d17, echo = FALSE, warning = FALSE, message = FALSE, error = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10}
# need to replace the adopt year to 0 if missing
data_CS <- data_no_ND %>% 
  mutate(adopt_year = ifelse(is.na(adopt_year), 0, adopt_year))

# run the CS algorithm
CS_out <- att_gt("ln_age_mort_rate2", data = data_CS,
                 first.treat.name="adopt_year",
                 idname="state", tname="Year", aggte = T,
                 bstrap=T, cband=T,
                 maxe = 4,
                 mine = -2,
                 nevertreated = F,
                 printdetails = F)

#plot
tibble(
  t = -3:3,
  estimate = CS_out$aggte$dynamic.att.e,
  se = CS_out$aggte$dynamic.se.e,
  conf.low = estimate - 1.96*se,
  conf.high = estimate + 1.96*se,
) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>%
  # plot
  ggplot(aes(x = t, y = estimate, group = band_groups)) + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "#E41A1C"), 
                  show.legend = FALSE, size = 1) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -3:3) + 
  labs(x = "Relative Time", y = "Estimate") + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 15))
```

---
# .center.pull[Abraham & Sun]
  
- Skip for now - without covariates it's the same as Callaway & Sant'Anna

---
# .center.pull[Cengiz et al.]
  
- First, we can plot the state-specific DiD estimates, separated by adoption period:
  
```{r d19, echo = FALSE, warning = FALSE, message = FALSE, error = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10, fig.height = 6}
# get all states treated during our data sample which have at least 2 pre and 2 post observations
obs <- data_no_ND %>% 
  filter(!is.na(adopt_year)) %>% 
  group_by(state) %>% 
  # get number of 0s and 1s
  mutate(num_0 = length(which(Medical_Cannabis_Law == 0)),
         num_1 = length(which(Medical_Cannabis_Law > 0))) %>% 
  # keep if there are at least 2 pre and 2 post periods
  filter(num_0 >= 2 & num_1 >= 2) %>% 
  pull(state) %>% 
  unique()

# make fomula to run with reduced datasets
formula_cldz <- as.formula("ln_age_mort_rate2 ~ Medical_Cannabis_Law | state + Year | 0 | 0")

# formula to calculate state-event-specific effects
rundid <- function(st) {
  
  # get the treatment year
  treat_yr <- data_no_ND %>% filter(state == st) %>% slice(1) %>% pull(adopt_year)
  
  # get a dataset with the the treated state and clean control states, keep only the years -3 to 3
  did_data <- data_no_ND %>% 
    # keep treated unit and all units not treated within -5 to 5
    filter(state == st | is.na(adopt_year) | adopt_year > treat_yr + 3) %>% 
    # keep just year -5, 5
    filter(Year >= treat_yr - 3 & Year <= treat_yr + 3)
  
  # run regs over the models
  did_data %>%
    do(fit = felm(formula_cldz, data = ., exactDOF = TRUE, cmethod = "reghdfe")) %>%
    broom::tidy(fit, conf.int = TRUE) %>%
    # keep just the indicator variable
    filter(term == "Medical_Cannabis_Law") %>% 
    # add in additional needed variables
    mutate(state = st,
           cohort = treat_yr)
}

# run over our states
plotdata <- map_df(obs, rundid)

# plot
plotdata %>% 
  mutate(rank = rank(estimate),
         cohort_type = ifelse(cohort <= 2010, "1997-2010", "2010-2019")) %>% 
  ggplot(aes(x = rank, y = estimate, 
             color = factor(cohort_type), group = factor(cohort_type))) + 
  geom_linerange(aes(ymin = conf.low, ymax = conf.high)) + 
  geom_point() + 
  labs(x = "Event", y = "Estimate and 95% CI") + 
  geom_hline(yintercept = 0, linetype = "dashed") + 
  coord_flip() + 
  scale_colour_brewer(palette = 'Set1') + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 15))
```

---
# .center.pull[Cengiz et al.]
  
```{r d20, echo = FALSE, warning = FALSE, message = FALSE, error = FALSE, fig.align = 'center', cache = TRUE, fig.width = 10, fig.height = 6}
# get the cohort years
obs <- data_no_ND %>% 
  filter(!is.na(adopt_year)) %>% 
  pull(adopt_year) %>% 
  unique()

# make fomula to run within our FE specification
# get the lead lags in one set of covariates
leadlags <- c("lag_3", "lag_2", "date_0",
              "lead_1", "lead_2", "lead_3")

# Make the estimating equation
formula_cldz2 <- as.formula(paste("ln_age_mort_rate2 ~", paste(leadlags, collapse = " + "), 
                                  "| factor(state):factor(df) + factor(Year):factor(df) | 0 | 0"))

# make formula to create the dataset
getdata <- function(i) {
  
  #keep what we need
  data_no_ND %>% 
    # keep treated units and all units not treated within -5 to 5
    filter(adopt_year == i | is.na(adopt_year) | adopt_year > i + 3) %>% 
    # keep just year -3 to 3
    filter(Year >= i - 3 & Year <= i + 3) %>%
    # create an indicator for the dataset
    mutate(df = i) %>% 
    # replace lead/lag indicators if not in the treatment cohort
    mutate(lag_3 = ifelse(is.na(adopt_year) | adopt_year != df, 0, lag_3),
           lag_2 = ifelse(is.na(adopt_year) | adopt_year != df, 0, lag_2),
           date_0 = ifelse(is.na(adopt_year) | adopt_year != df, 0, date_0),
           lead_1 = ifelse(is.na(adopt_year) | adopt_year != df, 0, lead_1),
           lead_2 = ifelse(is.na(adopt_year) | adopt_year != df, 0, lead_2),
           lead_3 = ifelse(is.na(adopt_year) | adopt_year != df, 0, lead_3))
}

# get data stacked
stacked_data <- map_df(obs, getdata)

# estimate the model on our stacked data
stacked_data %>% 
  # fit the model
  do(fit = felm(formula_cldz2, data = ., exactDOF = TRUE, cmethod = "reghdfe")) %>% 
  broom::tidy(fit, conf.int = TRUE) %>% 
  # keep just the variables we are going to plot
  filter(term %in% covariates_interest) %>% 
  # make a relative time variable
  mutate(t = c(-3:-2, 0:3)) %>% 
  select(t, estimate, conf.low, conf.high) %>% 
  # add in data for year -1
  bind_rows(tibble(t = -1, estimate = 0, 
                   conf.low = 0, conf.high = 0
  )) %>% 
  # split the error bands by pre-post
  mutate(band_groups = case_when(
    t < -1 ~ "Pre",
    t >= 0 ~ "Post",
    t == -1 ~ ""
  )) %>%
  # plot
  ggplot(aes(x = t, y = estimate, group = band_groups)) + 
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = band_groups),
              color = "lightgrey", alpha = 1/4) + 
  geom_pointrange(aes(ymin = conf.low, ymax = conf.high, color = "#E41A1C"), 
                  show.legend = FALSE, size = 1) + 
  geom_hline(yintercept = 0) +
  geom_vline(xintercept = -0.5, linetype = "dashed") + 
  scale_x_continuous(breaks = -3:3) + 
  labs(x = "Relative Time", y = "Estimate") + 
  theme(legend.position = "bottom",
        legend.title = element_blank(),
        axis.text = element_text(size = 15),
        axis.title = element_text(size = 15))
```

---
# .center.pull[Takeaways]
  
- DiDs are a powerful tool and we are going to keep using them.

- But we should make sure we understand what we're doing! DiD is a comparison of means and at a minimum we should know which means we're comparing. 

- Multiple new methods have been proposed, all of which ensure that you aren't using prior treated units as controls. 

- You should probably tailor your selection of method to your data structure: they use and discard different amount of control units and depending on your setting this might matter. 

- Unclear what's going on with MMLs and opioid mortality rates, but very unlikely that the results in the first published paper is robust.




