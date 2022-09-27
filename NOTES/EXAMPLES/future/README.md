# Using Brain with Future and Batchtools

## What is this? 

The instructions in this document describe how to configure Brain to allow you to submit jobs to Brain from an R session on another DEOHS server using the Future package. 

This set up will allow you to run R on your local server (such as Plasmid) that actually gets evaluated on the Brain cluster. You will be able to your code locally as you develop it, then switch the back-end to Brain cluster without changing any of your code when you're ready for "production". 

Once you've set up Future this way, you can either use the Future API itself or use any of several other packages that implement their distributed computing functionality using it (collectively called the "Futureverse").

For example:

- [future.apply](https://future.apply.futureverse.org/) (extends base "apply" functions)
- [doFuture](https://dofuture.futureverse.org/) (extends forEach)
- [furrr](https://furrr.futureverse.org/) (extends purrr)
- [targets](https://books.ropensci.org/targets/hpc.html) 

## Prereqs

 - You should know how to use `ssh` to connect to Brain and how to manipulate files via the command line. 
 - You must have access to Brain and to a group & queue (speak with IT to request). 
 - Even though you may end up using one of the packages above to actually interact with Future, it may be helpful to understand the very basics of how to use the [Future package](https://future.futureverse.org/). 

## Setup

1. Because Brain requires that you set a group and load R from a module each time you log in before using R,
we need to set up an alternative `Rscript` command that does all of this automatically. This directory contains an example script called `Rscript-4.1.0` that sets the group to `mesa` and calls `module load R/R-4.1.0`. Create the directory `~/bin` on Brain if it doesn't exist, then save the script there. This special location lets you call it as a standalone command. Don't forget to make it executable with `chmod +x ~/bin/Rscript-4.1.0`! 
  
    E.g. 
    
    ```
    [loganap@deohs-brain ~]$ Rscript-4.1.0 --version
    R scripting front-end version 4.1.0 (2021-05-18)
    ```
    
    If you get `bash: Rscript-4.1.0: command not found...` or similar, you may need to [add `~/bin` to your $PATH](https://askubuntu.com/questions/402353/how-to-add-home-username-bin-to-path).
  
2. Also copy `sge.tmpl` and `.batchtools.conf.R` into your home directory on Brain. If you don't see `.batchtools.conf.R` in this folder, it's there! It's just a hidden file (because it starts with `.`). If you are not in the `mesa` group, you will need to edit `.batchtools.conf.R` to identify the correct group and queue. You may already have copies of these files in your home directory on Brain. Unless you have done something non-standard with them, it should be safe to replace these files.  

3. Install `future` and `future.batchtools` onto *both* Brain and your "local" server (e.g. vector, plasmid). This is a good opportunity to test your new `Rscript` on Brain. If you want to run the example code in this directory, you should also install `listenv`. E.g. 

    ```
    [loganap@deohs-brain ~]$ Rscript-4.1.0 -e 'install.packages(c("future", "future.batchtools", "listenv"), dependencies = TRUE, repos = "http://cran.us.r-project.org", lib = Sys.getenv("R_LIBS_USER"))'
    ```
    
4. [Optional] You may find this more seamless if you set up an SSH key to allow password-free SSH connections between your local server and Brain. See steps 1-3 [here](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server). 

## Run a Future on the Cluster

Define the Future "plan" like so on your *local* server:

```
brain_headnode <- tweak(cluster, workers = "brain.deohs.washington.edu", rscript = 'Rscript-4.1.0', persistent = TRUE)
brain_sge_jobs <- tweak(batchtools_sge, template = 'sge.tmpl')

plan(list(brain_headnode, brain_sge_jobs))
```

The first line defines a Future with a remote connection to Brain's head node. Despite the name "cluster" this is actually just setting up one "worker" node via an ssh connection. The `rscript` argument tells Future that it will need to use the special `Rscript` command we set up in Step 1. 

The second line uses `future.batchtools` and the configuration details in `sge.tmpl` to define Future using **S**un **G**rid **E**ngine and to distribute jobs using that system. 

The third line creates a "plan" for Future to use, which tells it to first use `brain_headnode` to connect to Brain, then to dispactch jobs via SGE using `brain_sge_jobs`. 

See `example.R` for some example code to run with this setup. 


## Run a Future Locally

While you are developing your code and not ready to send it to Brain, you might want to run it locally. The simplest way to do this is to replace the `plan` above with a single line: `plan(sequential)`. If you run the code in `example.R` using `plan(sequential)`, you should see that all twenty of the "jobs" now get run on your local server. 

See the [Future Docs](https://future.futureverse.org/#controlling-how-futures-are-resolved) for details on alternative back-ends. 

## Alternative APIs

As mentioned above, some other packages have been extended to use Future as a back-end. There are examples using `purrr` and base `apply` in this directory. 
