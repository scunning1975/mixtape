library(readstata13)

setwd("/Users/hsantanna/Desktop")


####Example 1 - Page 84####
yule = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/yule.dta")

attach(yule)


  reg.yule = lm(paup ~ outrelief + old + pop)
  summary(reg.yule)
  
  
####Example 2 - Page 93####
  
gap = function() 
{
  df = data.frame(y1 = c(7,5,5,7,4,10,1,5,3,9),
                  y0 = c(1,6,1,8,2,1,10,6,7,8),
                  random = rnorm(10))
  
  df = df[order(df$random),]
  
  d = c(rep(1,5), rep(0,5))
  
  df$y = d * df$y1 + (1-d) * df$y0
  
  sy1 = mean(df$y[1:5])
  sy0 = mean(df$y[6:10])
  
  sdo = sy1 - sy0
  
  return(sdo)
}

sim = replicate(10000, gap())
mean(sim)


####Example 3 - Page 96-...###

star_sw <- read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/star_sw.dta")

#%#%#%#

star_reg <- lm(tscorek ~ sck + rak, data = star_sw)

summary(star_reg)


####Example 4 - Page 105####
  
  library(utils)
  cup <- seq(1,8)
  #she guesses tea before milk then stops
  guess <- c(1:4,0,0,0,0)
  cup_comb <- t(combn(cup, 4))
  colnames(cup_comb) <- c("cup_1", "cup_2", "cup_3", "cup_4")
  cup_comb <- as.data.frame(cup_comb)
  cup_comb$permutation <- c(1:70)
  
  cup_comb <- rbind(cup_comb, cup_comb, cup_comb, cup_comb,
                    cup_comb, cup_comb, cup_comb, cup_comb)
  
  cup_comb$guess <- guess
  
  cup_comb$correct <- ifelse(cup_comb$cup_1 == 1 & 
                             cup_comb$cup_2 == 2 &
                             cup_comb$cup_3 == 3 & 
                             cup_comb$cup_4 == 4, 1, 0)
  
  sum(cup_comb$correct == 1)/nrow(cup_comb)
  
  
  
  
 # lady <- data.frame(actual = rep(c("Milk", "Tea"), each= 4), guess = rep(c("Milk", "Tea"), each= 4))
#  tab <- with(lady, table(guess, actual)); tab
#  fisher.test(tab, alt="greater")
  
  
  
####Example 4 - Page 113####
  library(readstata13)
  ri = read.dta13("https://storage.googleapis.com/causal-inference-mixtape.appspot.com/ri.dta")
  ri$id <- c(1:8)
  
  comb_id <- as.data.frame(t(combn(ri$id,4)))
  colnames(comb_id) <- c("treated1", "treated2", "treated3", "treated4")
  comb_id$permutation <- c(1:nrow(comb_id))
  comb_id <- merge(comb_id, ri)
  
  comb_id$d <- ifelse(comb_id$id == comb_id$treated1 |
                        comb_id$id == comb_id$treated2 |
                        comb_id$id == comb_id$treated3 |
                        comb_id$id == comb_id$treated4, 1, 0)
  
  comb_id$te1 <- ifelse(comb_id$d == 1, ave(comb_id$y, comb_id$permutation, comb_id$d), NA)
  comb_id$te0 <- ifelse(comb_id$d == 0, ave(comb_id$y, comb_id$permutation, comb_id$d), NA)

  comb_id <- aggregate(comb_id, by=list(comb_id$permutation), 
            FUN=mean, na.rm=TRUE)
  comb_id <- comb_id[c(6, length(comb_id)-1, length(comb_id))]
  
  comb_id$ate <- comb_id$te1-comb_id$te0
  comb_id <- comb_id[order(comb_id$ate, decreasing = FALSE),]
  comb_id$rank <- c(1:nrow(comb_id))
  
  mean(comb_id$rank[comb_id$permutation == 1]/70)
  
  #This is weird#
  
  #TALK TO CUNNINGHAM 
  #summary(comb_id$rank[comb_id$permutation == 1])
  