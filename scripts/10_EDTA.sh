#!/usr/bin/env bash

#SBATCH --cpus-per-task=50
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --job-name=EDTA
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/10_EDTA_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/10_EDTA_%j.e


# Define input and output directories
# User needs to provide path to the project directory which also contains all the polished genome assemblies i.e., source
# User also needs to provide path to the destination folder where output data should be deposited i.e., destination
# Example: 10_EDTA.sh </path/to/source/> </path/to/destination>
source=$1
destination=$2

# Set the variable REF_GEN to the directory path to the reference genome and other associated files and tools are
# Change this depending on where the reference genome and associated files are.
REF_GEN=/data/courses/assembly-annotation-course

# Prepare aliases to use later. Done for convenience.
ANNODIR=${source}/additional_material/TAIR10_cds_20110103_representative_gene_model_updated
# Change this depending on which assembly you want to annotate. I chose polished Flye assembly as it was the best assembly for me.
GENOME=${source}/analysis/05_Polished_genome_assemblies/mapped_bam_files/Flye_polished.fasta


# Make a directory to store the EDTA analysis results and go to it
mkdir -p ${destination}/08_EDTA
cd ${destination}/08_EDTA

# singularity exec: used to run a command within a Singularity container
# --bind: flag used to bind mount directories from the host system into the Singularity container. In this case, it binds the $REF_GEN and $source directories into the container.
# $REF_GEN/containers2/EDTA_v1.9.6.sif EDTA.pl:to provide path to the EDTA Singularity container
# --genome $GENOME: Specifies the input genome file for the EDTA analysis.
# --species others: Specifies the species for the analysis.
# --step all: Specifies to perform all steps of the analysis.
# --cds $ANNODIR: Specifies the directory containing the annotated coding sequences.
# --anno 1: Specifies to use the provided annotation.
# --threads 50: Specifies the number of threads to use for parallel processing for the analysis.


singularity exec \
--bind $REF_GEN \
--bind $source \
$REF_GEN/containers2/EDTA_v1.9.6.sif \
EDTA.pl \
--genome $GENOME --species others --step all --cds $ANNODIR --anno 1 --threads 50

