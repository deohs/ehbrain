# Using HOMER on Brain

Since HOMER is designed to be installed on a per-user basis, these instructions don't
follow our normal recommendations.

## Install

### Add Miniconda to your path and create the conda environment

module load Anaconda/Miniconda3-4.5.12

mkdir -p ~/conda_env

conda create --prefix /home/jtyocum/conda_env/homer

### Activate the newly created environment, and install dependencies

source activate /home/jtyocum/conda_env/homer

conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda install wget samtools r-essentials bioconductor-deseq2 bioconductor-edger

### Install HOMER within the environment
mkdir -p ~/conda_env/homer/homer

cd ~/conda_env/homer/homer

wget http://homer.ucsd.edu/homer/configureHomer.pl

perl configureHomer.pl -install

## Usage

You'll need to perform the following steps any time you wish to use HOMER on Brain.

### Add Miniconda to your path, and activate the HOMER environment

module load Anaconda/Miniconda3-4.5.12
source activate /home/jtyocum/conda_env/homer

### Add HOMER to your path

export PATH=$PATH:/home/jtyocum/conda_env/homer/homer/.//bin/