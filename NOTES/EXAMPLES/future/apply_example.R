library(future)
library(future.batchtools)
library(future.apply)
library(nycflights13)

# Model the nycflights::flights data set. Regress departure delay on departure time by carrier and origin. 
# Collect the intercept and slope from each. 

# Basic apply / sapply 
flights_split <- flights %>%
  split(interaction(.$carrier, .$origin), drop = TRUE) 

flights_lms <- lapply(flights_split, function(df) lm(data = df, dep_delay ~ dep_time)) 
data.frame(t(sapply(flights_lms, function(mod) as.matrix(coef(mod)))))

# Running locally using future.apply (functionally same as above)
plan(sequential)
flights_lms <- future_lapply(flights_split, function(df) lm(data = df, dep_delay ~ dep_time)) 
data.frame(t(future_sapply(flights_lms, function(mod) as.matrix(coef(mod)))))


# Running on Brain (note that the code doesn't change except for the `plan` definition
brain_headnode <- tweak(cluster, workers = "brain.deohs.washington.edu", rscript = 'Rscript-4.1.0', persistent = TRUE)
brain_sge_jobs <- tweak(batchtools_sge, template = 'sge.tmpl')
plan(list(brain_headnode, brain_sge_jobs))
flights_lms <- future_lapply(flights_split, function(df) lm(data = df, dep_delay ~ dep_time)) 
data.frame(t(future_sapply(flights_lms, function(mod) as.matrix(coef(mod)))))

