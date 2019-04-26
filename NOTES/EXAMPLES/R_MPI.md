# Using R with MPI

*NOTE:* This example is a work in progress.

This is an example of using Rmpi on Brain.

## Setup the Environment

    module purge
    module load OpenMPI/openmpi-4.0.1 
    module load R/R-3.5.3 

## Install Rmpi

    install.packages('Rmpi', configure.args = "--with-mpi=/share/apps/OpenMPI/openmpi-4.0.1")

## Job

    mpirun --prefix /share/apps/OpenMPI/openmpi-4.0.1 -x PATH -x LD_LIBRARY_PATH R CMD BATCH Rmpi.R
