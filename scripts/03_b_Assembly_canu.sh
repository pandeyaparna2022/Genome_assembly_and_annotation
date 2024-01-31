#!/usr/bin/env bash

#SBATCH --time=2-00:00:00
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=canu_assembly
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/03_b_canu_assembly_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/03_b_canu_assembly_%j.e


# define input data and output directories
source=$1
destination=$2

# Load the required module(s)
module load UHTS/Assembler/canu/2.1.1;

# change directory yo the destination directory
cd ${destination}

# Make a directory to store the output data. -p option is used to avoid an error if a directory of that name already exists. If the directory already exists and output file names match any of the file names in the directory, those files will be overwritten.
mkdir -p 03_genome_assemblies/Canu_genome_assembly

# change directory to the output directory
cd 03_genome_assemblies/Canu_genome_assembly
# Define a function that carries out canu assembly

# Function to perform Canu assembly
run_canu_assembly() {
    # set SEQ_METHOD variable to "pacbio",indicating the sequencing method used for the input files.
    SEQ_METHOD="pacbio"
    # Create an array FILES containing all the .fastq.gz files from the source directory
    FILES=(${source}/*.fastq.gz)
    # Define the OUTPUT_FILE and OUTPUT_DIR
    OUTPUT_FILE="Canu_${SEQ_METHOD}"
    OUTPUT_DIR=${destination}/03_genome_assemblies/Canu_genome_assembly
    # Create a loop that iterates through the FILES array in pairs, reflecting the fact that these are paired-end sequencing files, and assigns FILE1 and FILE2 accordingly. Depending on the organization of your files in the source directory, you may need to adjust this section. In this scenario, the paired-end files are located consecutively, so the loop progresses in intervals of two.
    for ((i = 0; i < ${#FILES[@]}; i += 2)); do
        FILE1="${FILES[i]}"
        FILE2="${FILES[i + 1]}"
        echo $FILE1
	echo $FILE2
    # Execute Canu tool with the following parameters:
    # -pacbio "$FILE1" "$FILE2" - Specifies that the input files are in PacBio format and the variables $FILE1 and $FILE2 are used to reference the paths to the input files.
    # -d "$OUTPUT_DIR" - sets the output directory for the assembly results.
    # genomeSize=133725193 - Specifies the estimated genome size for assembly.
    # -p "$OUTPUT_FILE" -  Sets the prefix for output files to be the value of OUTPUT_FILE.
    
    # The rest are additional suggested configurations for running Canu on the cluster
    # maxThreads=16: Specifies the maximum number of threads to use during the assembly process for parallel processing.
    # maxMemory=64: Sets the maximum memory limit for the assembly process
    # gridEngineResourceOption="--cpus-per-task=THREADS --mem-per-cpu=MEMORY": Defines the resource options for the grid engine, specifying the number of CPUs per task and memory per CPU.
    # gridOptions="--partition=pall": Specifies additional grid options, such as the partition to use, etc which are otherwise added to the sbatch options.
    canu maxThreads=16 maxMemory=64 gridEngineResourceOption="--cpus-per-task=THREADS --mem-per-cpu=MEMORY --time=2-00:00:00" gridOptions="--partition=pall" -p "$OUTPUT_FILE" genomeSize=133725193 -d "$OUTPUT_DIR" -pacbio "$FILE1" "$FILE2"
    done 
}

# Canu can be without creating a function (similar to how flye was excuted). I used a function here to demonstrate a different way of running Canu if we have multiple sets of files. 

# call the function to invoke and execute Canu genome assembly tool with the specified parameters and options
run_canu_assembly 

