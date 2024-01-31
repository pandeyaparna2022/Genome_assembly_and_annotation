#!/usr/bin/env bash
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=flye_genome_assembly
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/03_a_fly_genome_assembly_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/03_a_fly_genome_assembly_%j.e

# define input data and output directories
source=$1
destination=$2

# Load the required module(s)
module load UHTS/Assembler/flye/2.8.3

# change directory yo the destination directory
cd ${destination}

# Make a directory to store the output data. -p option is used to avoid an error if a directory of that name already exists. If the directory already exists and output file names match any of the file names in the directory, those files will be overwritten.
mkdir -p 03_genome_assemblies/Flye_genome_assembly

# change directory to the output directory
cd 03_genome_assemblies/Flye_genome_assembly

# Creates an array of file paths matching the pattern *.fastq.gz in the specified directory
FILES=(${source}/*.fastq.gz)

# Create a loop that iterates through the FILES array in pairs, reflecting the fact that these are paired-end sequencing files, and assigns FILE1 and FILE2 accordingly. Depending on the organization of your files in the source directory, you may need to adjust this section. In this scenario, the paired-end files are located consecutively, so the loop progresses in intervals of two.
for ((i = 0; i < ${#FILES[@]}; i += 2)); do
        FILE1="${FILES[i]}"
        FILE2="${FILES[i + 1]}"
    
# Execute flye tool with the following parameters:
# --pacbio-raw "$FILE1" "$FILE2" -  specifies the input data for the assembly. It indicates that the input data consists of PacBio raw reads from two files, representing paired-end PacBio reads. The variables $FILE1 and $FILE2 are used to reference the paths to the input files.
# --out-dir ${destination}/Flye_genome_assembly - specifies the output directory where the assembly results will be written. 
# --threads 16 - specifies the number of threads or CPU cores to be used for the assembly for parallel processing.
    flye --pacbio-raw "$FILE1" "$FILE2" --out-dir ${destination}/03_genome_assemblies/Flye_genome_assembly --threads 16
    done
