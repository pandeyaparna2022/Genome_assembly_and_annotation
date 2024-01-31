#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=00:02:00
#SBATCH --job-name=Orthofinder
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/17_parse_orthofinder_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/17_parse_orthofinder_%j.e
#SBATCH --partition=pall


# Define Input directory and script directory
OUTPUT_DIR=$1
SCRIPT_DIR=$2

# Load R module if required
module load R/3.6.1;

#Define directories for input data
WORKING_DIR=${OUTPUT_DIR}/orthofinder/*/
cd ${WORKING_DIR}

WORKING_DIR1=$(pwd)/Comparative_Genomics_Statistics
WORKING_DIR2=$(pwd)/Orthogroups


# Set the personal library path
export R_LIBS_USER="/home/apandey/R/x86_64-koji-linux-gnu-library/3.6/"
export OUTPUT_DIR
export WORKING_DIR1
export WORKING_DIR2

#cd ${WORKING_DIR1

# Run R script
Rscript ${SCRIPT_DIR}/17_parse_orthofinder.R

