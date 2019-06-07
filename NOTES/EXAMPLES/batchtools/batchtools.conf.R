
default.resources = list(queue="mesa.q", group="mesa",ncpus=2,blas.threads=2)
 
#by default, give a SGE task 2 cores and tells the math library mkl to use 2 threads.
 #this effectively makes it so each task gets a full dedicated physical core and doesn't share that core with other SGE tasks. setting blas.threads allows the possiblity that  R may make use of hyperthreading via mkl (depends on the R function)
 #note that you can also set max.concurrent.jobs here. this might be a way to prevent any individual process from ever using a certain number of cores, regardless of how many are available.


cluster.functions = makeClusterFunctionsSGE("~/sge.tmpl") #by default use the cluster (without this, batchtools will default to "intercative" which would be parallelism on the head node...)
