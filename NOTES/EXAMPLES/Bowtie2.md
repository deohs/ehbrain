# Bowtie2 Example

## Running Bowtie2 on Brain

Here is a basic example of running Bowtie2 and SAMtools on Brain. In this example,
Bowtie2 will be performing the alignment, and SAMtools will convert the result into
a compressed BAM file.

For this example, I am using some predefined environment variables to reduce typing
and increase reusability. The first is *PWD*, which stands for Present Working Directory.
At the start of the job, PWD will be set to the directory you started the job. To preserve
that value, we copy it into the JOBDIR variable. The second environment variable is *TMPDIR*,
this is set to a unique path per-job, and points to a directory on the compute node's high
speed local disk.

Since an alignment can involve a lot of read/write activity, when possible you should copy
the data files to the node's local disk. Then, have the tools output to local disk. Finally,
copy the resulting output back to Brain's storage. To demonstrate this process, these steps
are included in the example.

Finally, this example makes the assumption that your reads, index, and reference genomes
are all in the same directory.

## Example Batch Job File

    #!/bin/bash
    #$ -N bt2_lambda_virus
    #$ -q mesa.q
    #$ -S /bin/bash
    #$ -cwd
    #$ -pe smp 4
    
    # Save the original working directory
    JOBDIR=$PWD
    
    # Copy the files to the temporary job directory
    cp $JOBDIR/*.fq $TMPDIR
    cp $JOBDIR/*.bt2 $TMPDIR
    
    # Change the working directory to temporary job directory
    cd $TMPDIR
    
    # Load bowtie2 and samtools modules
    module load Bowtie2/bowtie2-2.3.5
    module load SAMtools/samtools-1.9
    
    # Run bowtie2 and samtools
    bowtie2 -p 4 -x lambda_virus -1 reads_1.fq -2 reads_2.fq -S lambda_virus.sam
    samtools view -b -h -o lambda_virus.bam lambda_virus.sam
    
    # Copy the resulting files back to the job directory
    cp *.sam $JOBDIR
    cp *.bam $JOBDIR
