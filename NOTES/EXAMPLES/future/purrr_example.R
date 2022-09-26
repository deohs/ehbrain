library(future)
library(future.batchtools)
library(purrr)
library(furrr)
library(dplyr)
library(nycflights13)

# Model the nycflights::flights data set. Regress departure delay on departure time by carrier and origin. 
# Collect the intercept and slope from each. 

# Basic purrr
flights %>%
  split(interaction(.$carrier, .$origin), drop = TRUE) %>%
  map(~ lm(dep_delay ~ dep_time, data = .x)) %>%
  map_dfr(~ as.data.frame(t(as.matrix(coef(.)))))

# Running locally using furrr (functionally same as above)
plan(sequential)
flights %>%
  split(interaction(.$carrier, .$origin), drop = TRUE) %>%
  future_map(~ lm(dep_delay ~ dep_time, data = .x)) %>%
  future_map_dfr(~ as.data.frame(t(as.matrix(coef(.)))))

# Running on Brain (note that the code doesn't change except for the `plan` definition
brain_headnode <- tweak(cluster, workers = "brain.deohs.washington.edu", rscript = 'Rscript-4.1.0', persistent = TRUE)
brain_sge_jobs <- tweak(batchtools_sge, template = 'sge.tmpl')
plan(list(brain_headnode, brain_sge_jobs))
flights %>%
  split(interaction(.$carrier, .$origin), drop = TRUE) %>%
  future_map(~ lm(dep_delay ~ dep_time, data = .x)) %>%
  future_map_dfr(~ as.data.frame(t(as.matrix(coef(.)))))
