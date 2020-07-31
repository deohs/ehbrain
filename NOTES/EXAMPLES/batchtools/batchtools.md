# Using batchools to distribute R tasks 

This is an example of using batchools on Brain.

## Install batchools in R

    install.packages('batchtools')
    
## Overview
batchools automates submission of tasks to SGE from within R.  

Typically, each submission will contain a single task using a single core.

## Create your template file

Start from the example file in this directory. This should be placed in your home directory (~/) and be named `sge.tmpl`
   
This is a template which batchools will use to submit jobs to SGE. It is written like a .sh file for submitting jobs to SGE, except that it contains parameters which are filled in by R batchtools for each job. 

These parameters can include number of cpus and SGE queue. 

## Create your configuration file

Start from the example file in this directory. This should be placed in your home directory (`~/`) and be renamed `.batchtools.conf.R` (note the period before the filename).

If you're using a queue other than mesa, be sure to change the `group` and `queue` values in the `default.resources` list.

This is an .R file which contains batchtools functions to tell batchtools what resources to use by default. 
Specifically, this ensures that batchtools knows to use the SGE cluster by default. In this file you can also specify default computational resource values (these get passed as arguments to the template file). 


## Create an R script
See https://mllg.github.io/batchtools/articles/batchtools.html for instructions on R functions. 

Most basically, your script will contain something like this:

    library(batchtools)
     
     #create a registry and specify what directory you would like that registry in
    tmp <- makeRegistry()
        #by default the registry is a batchtool directory that keeps track of its submission of jobs to SGE is placed in the current R working directory
    
    f <- function(arg,setting){Sys.sleep(30);TRUE}
    batchMap(fun=f, arg=1:10,more.args=list(setting=1)) #arguments provided to ... will be exucted as seperate calls, parallel. more.args are arguments  that are constant across all function calls.
    submitJobs()
    waitForJobs()
    reduceResultsList()
    
    


## Load your group, Set up your environment, load R:
    
    newgrp mesa
    module purge
    module load R/R-3.5.3 
    R
    source("myRscript.R")
    

## Other notes
Your jobs should be visible by typing qstat in a different session of brain. If R crashes, you can load your previous registry and see which tasks are still running.

If you need to delete a range of tasks in SGE you can do `qdel{x..y}`.

If you want to rerun your script from scratch you'll need to delete your registry
`rm registry -r`


## Memory

The provided template files cap the memory usage of a job to the approximate number of gigs of ram per core on the mesa.q nodes (the latest nodes have the same number of memory with more cores so with setting some processores on those nodes won't be used).

If your processes use more than ~7.8G of memory each, you can specifically request more memory via:
     
     submitJobs(resources=list(mem="20G"))

for example. This requests 20G of memory per job. If the memory is not available, the job will sit in the queue until that much memory becomes available on any node.

Note that if a job exceeds the value of virtual_free (specified via mem passed to sge.tmpl), then the job will likely be killed by sge.tmpl although I haven't tested this specifically. 

     

