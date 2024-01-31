#!/usr/bin/env bash

#SBATCH --time=1:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --partition=pall
#SBATCH --job-name=meryl_create_db
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/07_meryl_database_preparation_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/07_meryl_database_preparation_%j.e

#User needs to input path to the directory where the input data is (source) and the path to the directory where output data should go (destination) when running the script with sbatch
#example: sbatch 07_a_Mercury_db.sh </path/to/source/> </path/to/destination>

# define input data and output directories
source=$1
destination=$2

# load the required  module(s)
# meryl is included in canu
module load UHTS/Assembler/canu/2.1.1;

# Change directory yo the destination directory
cd ${destination}

# Create a directory for assembly evaluation
mkdir -p 06_Assembly_evaluation

# Change directory to the assembly evaluation directory
cd 06_Assembly_evaluation

# Create a directory for Mercury analysis
mkdir -p Mercury_Analysis

# Change directory to the Mercury analysis directory
cd Mercury_Analysis

# Define input and output directories
# meryl is a tool for counting k-mers in DNA sequences
# Use meryl tool to create k-mer databases for read 1 and read 2 (from paired-end short reads), and then merges these databases to produce a single meryl database containing the union of k-mer counts from both read sets.

# It compares k-mers of an assembly with the k-mers of unassembled high-accuracy reads (e.g. Illumina reads).
# meryl k=19 count output $SCRATCH/$file_name.meryl ${source}/*1.fastq.gz: This command counts the occurrences of k-mers of length 19 (specified by k=19) in the indicated file (in the directory specified by ${source}). The resulting k-mer counts are stored in the indicated file ($file_name.meryl) within the directory specified by $SCRATCH (temporary storage location).
meryl k=19 count output $SCRATCH/read_1.meryl ${source}/*1.fastq.gz
meryl k=19 count output $SCRATCH/read_2.meryl ${source}/*2.fastq.gz

# meryl union-sum output ./illumina.meryl ${SCRATCH}/read*.meryl: This command merges the read_1.meryl and read_2.meryl (created in the last step) databases together and calculates the union of k-mer counts. The resulting merged database is saved as illumina.meryl in the current working directory.

meryl union-sum output ./database.meryl $SCRATCH/read*.meryl

