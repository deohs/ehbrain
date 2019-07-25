# QIIME2 Example

This example is based on the tutorial from https://docs.qiime2.org/2019.1/tutorials/atacama-soils/.

## Running QIIME2

Similar to the Bowtie2 example, this example utilizes some standard environment variables
to reduce typing. As with the other example, it uses both *PWD* and *TMPDIR*. In addition,
since a QIIME2 workflow has several intermediate files, we recommend copying the input data
to the node's local disk, and running the compute job with the copy. Once the job completes,
it should copy the resulting files back Brain's main storage. This type of workflow is included
in the following example.

Finally, the example makes the assumption that the input files are in the same directory as
the job file. And, that the job file is being submitted from that directory.

## Example Batch File

    #!/bin/bash
    #$ -N q2-atacama-soils 
    #$ -q mesa.q
    #$ -S /bin/bash
    #$ -cwd
    #$ -pe smp 4
    
    # Save the original working directory
    JOBDIR=$PWD
    
    # Copy the files to the temporary job directory
    cp $JOBDIR/*.tsv $TMPDIR
    cp -r $JOBDIR/emp-paired-end-sequences/ $TMPDIR
    
    # Change the working directory to temporary job directory
    cd $TMPDIR
    
    # Load Miniconda and QIIME2 modules
    module load Anaconda/Miniconda3-4.5.12
    module load QIIME2/qiime2-2019.1
    
    # Activate the QIIME2 Python Environment
    source activate /share/apps/QIIME2/qiime2-2019.1
    
    # Run qiime2
    qiime tools import \
      --type EMPPairedEndSequences \
      --input-path emp-paired-end-sequences \
      --output-path emp-paired-end-sequences.qza
    
    qiime demux emp-paired \
      --m-barcodes-file sample-metadata.tsv \
      --m-barcodes-column BarcodeSequence \
      --i-seqs emp-paired-end-sequences.qza \
      --o-per-sample-sequences demux.qza \
      --p-rev-comp-mapping-barcodes
    
    qiime demux summarize \
      --i-data demux.qza \
      --o-visualization demux.qzv
    
    qiime dada2 denoise-paired \
      --p-n-threads $NSLOTS \
      --i-demultiplexed-seqs demux.qza \
      --p-trim-left-f 13 \
      --p-trim-left-r 13 \
      --p-trunc-len-f 150 \
      --p-trunc-len-r 150 \
      --o-table table.qza \
      --o-representative-sequences rep-seqs.qza \
      --o-denoising-stats denoising-stats.qza
    
    qiime feature-table summarize \
      --i-table table.qza \
      --o-visualization table.qzv \
      --m-sample-metadata-file sample-metadata.tsv
    
    qiime feature-table tabulate-seqs \
      --i-data rep-seqs.qza \
      --o-visualization rep-seqs.qzv
    
    qiime metadata tabulate \
      --m-input-file denoising-stats.qza \
      --o-visualization denoising-stats.qzv
     
    # Copy the resulting files back to the job directory
    cp *.qza $JOBDIR
    cp *.qzv $JOBDIR
