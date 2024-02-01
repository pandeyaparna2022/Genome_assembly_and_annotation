#!/bin/bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=48G
#SBATCH --cpus-per-task=12
#SBATCH --job-name=trinity_assembly
#SBATCH --partition=pall
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/04_Trinity_assembly_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/04_Trinity_assembly_%j.e

#User needs to provide input path to the directory where the input data (Illumina paired end RNAseq reads) is (source) and the path to the directory where output data should go (destination) when running the script with sbatch
#example: sbatch 04_perform_trinity_assembly.sh </path/to/source/> </path/to/destination>
source=$1
destination=$2

# load the needed module(s)
module load UHTS/Assembler/trinityrnaseq/2.5.1;
 
# Change directory to destination directory
cd ${destination}

# Make a directory to store the output data. -p option is used to avoid an error if a directory of that name already exists. If the directory already exists and output file names match any of the file names in the directory, those files will be overwritten. Ensure 'trinity' in the directory name.

mkdir -p 04_trinity_transcriptome_assembly

# change directory to the output directory
cd 04_trinity_transcriptome_assembly

# Define a function that carries out Trinity assembly

# Function to perform Trinity assembly
run_trinity_assembly() {
    # Define OUTPUT_DIR
    OUTPUT_DIR=${destination}/04_trinity_transcriptome_assembly/
    # Create an array FILES containing all the .fastq.gz files from the source directory
    FILES=("$source"/*.fastq.gz)
    # Create a loop that iterates through the FILES array in pairs, reflecting the fact that these are paired-end sequencing files, and assigns FILE1 and FILE2 accordingly. Depending on the organization of your files in the source directory, you may need to adjust this section. In this scenario, the paired-end files are located consecutively, so the loop progresses in intervals of two.
    for (( i=0; i < ${#FILES[@]}; i += 2 )); do
    FILE1="${FILES[i]}"
    FILE2="${FILES[i + 1]}"
    # Execute Trinity assembly software for each pair of files with following parameters:
    # --seqType fq: Specifies the sequence type as "fq" (for FASTQ format).Note: fa is used for FASTA file.
    # --SS_lib_type option: Specifies the strand-specific library type aindicating the orientation of the paired-end reads. WE DID NOT USE THIS OPTION HERE AS OUR LIBRARY IS NOT STRANDED. this is just for information in case of a stranded library
    # --left $FILE1: Specifies the path to the left (forward) reads of the paired-end RNA-seq data
    # --right $FILE2: Specifies the path to the right (reverse) reads of the paired-end RNA-seq data.
    # --output "$OUTPUT_DIR": Specifies the output directory for storing the Trinity assembly results.   
    # --CPU 12: Allocates 12 CPU cores for the Trinity assembly process.
    # --max_memory 48G: Sets the maximum memory allocation to 48 gigabytes for the Trinity assembly.
       
    Trinity --seqType fq --left $FILE1 --right $FILE2 --output $OUTPUT_DIR --CPU 12 --max_memory 48G
done
}

# call the function to invoke and execute Trinity assembly tool with the specified parameters and options
run_trinity_assembly
