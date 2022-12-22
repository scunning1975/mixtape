library(haven)

read_data <- function(df)
{
  full_path <- paste("https://github.com/scunning1975/mixtape/raw/master/", 
                     df, sep = "")
  df <- read_dta(full_path)
  return(df)
}
