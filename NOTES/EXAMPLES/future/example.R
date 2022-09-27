library(future)
library(future.batchtools)
library(listenv)

brain_headnode <- tweak(cluster, workers = "brain.deohs.washington.edu", rscript = 'Rscript-4.1.0', persistent = TRUE)
brain_sge_jobs <- tweak(batchtools_sge, template = 'sge.tmpl')

plan(list(brain_headnode, brain_sge_jobs))

# Dispatch jobs to the cluster and collect the hostnames & PIDs for each job
x %<-% {
  thost <- Sys.info()[["nodename"]]
  tpid <- Sys.getpid()
  y <- listenv()
  for (task in 1:20) {
    ## (b) This will be evaluated on a compute node on the cluster
    y[[task]] %<-% {
      mhost <- Sys.info()[["nodename"]]
      mpid <- Sys.getpid()
      z <- listenv()
      for (jj in 1:2) {
        ## (c) These will be evaluated in separate processes on the same compute node
        z[[jj]] %<-% data.frame(task = task,
                                top.host = thost, top.pid = tpid,
                                mid.host = mhost, mid.pid = mpid,
                                host = Sys.info()[["nodename"]],
                                pid = Sys.getpid(),
                                r.version = getRversion())
      }
      Reduce(rbind, z)
    }
  }
  Reduce(rbind, y)
} %seed% 8675309 # set seed to avoid warning from future

View(x)
