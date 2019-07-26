# Cufflinks Example

## Running Cufflinks

This is example is very similar to the QIIME2 and Bowtie2 examples. Like those
examples, it uses environment variables to reduce typing, and leverages the compute
node's high speed local disk to speed up data I/O.

One improvement you could make on this example, would be to put the input and output
data into separate subfolders. As a result, the copy commands would need to be modified
to perform a recursive copy of those directories.

## Example Batch File

    #!/bin/bash
    #$ -N cufflinks
    #$ -q mesa.q
    #$ -S /bin/bash
    #$ -cwd
    #$ -pe smp 4
    
    # Save the original working directory
    JOBDIR=$PWD
    
    # Copy the files to the temporary job directory
    cp $JOBDIR/*.sam $TMPDIR
    
    # Change the working directory to temporary job directory
    cd $TMPDIR
    
    # Load cufflinks modules
    module load Cufflinks/cufflinks-2.2.1
    
    # Run cufflinks 
    cufflinks -p $NSLOTS test_data.sam
    
    # Copy the resulting files back to the job directory
    cp *.gtf $JOBDIR
    cp *.fpkm_tracking $JOBDIR
