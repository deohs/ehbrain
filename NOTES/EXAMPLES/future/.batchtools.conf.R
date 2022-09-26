
default.resources = list(queue="mesa.q", group="mesa",ncpus=1,blas.threads=1,
	      Rversion=paste0(R.Version()$major,".",R.Version()$minor),
	      mem="7.8G")

#by default, give a SGE task 1 cores and tells the math library mkl to use 1 threads.
#depending on your application, it may be better to switch this to ncpus=2, blas.threads=2. 
 #note that you can also set max.concurrent.jobs here. this might be a way to prevent any individual process from ever using a certain number of cores, regardless of how many are available.


cluster.functions = makeClusterFunctionsSGE("~/sge.tmpl") #by default use the cluster (without this, batchtools will default to "intercative" which would be parallelism on the head node...)
