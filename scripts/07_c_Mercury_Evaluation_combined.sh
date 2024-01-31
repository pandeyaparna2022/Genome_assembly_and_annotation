#!/usr/bin/env bash

#SBATCH --time=00:30:00
#SBATCH --mem=48G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=merqury_analysis
#SBATCH --partition=pall
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/07_meryl_combined_kmercount_analysis_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/07_meryl_combined_kmercount_analysis_%j.e


# define input and output directories
# User needs to provide path to the entire assembly directory as we need to bind this to the container, allowing the container to access files and directories within the directory.
# example: sbatch 07_b_Mercury_Evaluation.sh </path/to/assembly_directory>

assembly_directory=$1

INPUT_FLYE_POLISHED_ASSEMBLY=${assembly_directory}/analysis/05_Polished_genome_assemblies/mapped_bam_files/Flye_polished.fasta
INPUT_CANU_POLISHED_ASSEMBLY=${assembly_directory}/analysis/05_Polished_genome_assemblies/mapped_bam_files/Canu_polished.fasta

MERYL_DIR=${assembly_directory}/analysis/06_Assembly_evaluation/Mercury_Analysis/database.meryl
OUTPUT_DIR=${assembly_directory}/analysis/06_Assembly_evaluation/Mercury_Analysis/

mkdir -p ${OUTPUT_DIR}

# Mercury script can be run with following available parameters/options:

#merqury.sh <read-db.meryl> [<mat.meryl> <pat.meryl>] <asm1.fasta> [asm2.fasta] <out>
#<read-db.meryl>: Represents the k-mer counts of the read set
#<mat.meryl>: Represents the k-mer counts of the maternal haplotype (e.g., mat.only.meryl or mat.hapmer.meryl)
#<pat.meryl>: Represents the k-mer counts of the paternal haplotype (e.g., pat.only.meryl or pat.hapmer.meryl)
#<asm1.fasta>: Represents the assembly fasta file (e.g., pri.fasta, hap1.fasta, or maternal.fasta)
#[asm2.fasta]: Represents an additional fasta file (e.g., alt.fasta, hap2.fasta, or paternal.fasta)
#*asm1.meryl and asm2.meryl will be generated. It's advised to avoid using the same names as the hap-mer dbs.
#<out>: Represents the output prefix
#< > : Indicates required parameters

# Mercury analysis is carried out from within a Singularity container. 

# apptainer exec: This is the command to execute a process within a Singularity container using the "apptainer" tool
# --bind ${assembly_directory}: The --bind option is used to bind-mount the directory specified by the variable ${assembly_directory} into the Singularity container. This allows the process running inside the container to access files and directories from the host system
# /software/singularity/containers/Merqury-1.3-1.ubuntu20.sif: Specifies the path to the Singularity container image named "Merqury-1.3-1.ubuntu20.sif". The "apptainer" tool uses this image to create an isolated environment for running the subsequent command.
# merqury.sh <d-db.meryl> <asm1.fasta> <output_prefix>: specifies the command to be executed within the Singularity container. It invokes a script named "merqury.sh" with the arguments <d-db.meryl> <asm1.fasta>

# Chnage directory to path specified by the variable OUTPUT_DIR
cd ${OUTPUT_DIR}

# Run Mercury analysis on unpolished flye assembly
# Make a custopm directory for results and go to that directory
mkdir -p ${OUTPUT_DIR}/combined
cd ${OUTPUT_DIR}/combined

# grant read, write, and execute permissions to all users (owner, group, and others) for the assembly file
#chmod a+rwx ${INPUT_FLYE_UNPOLISHED_ASSEMBLY}
# assign the value "Flye_unpolished" to the variable output_prefix
output_prefix=combined

apptainer exec \
--bind "${assembly_directory}" \
/software/singularity/containers/Merqury-1.3-1.ubuntu20.sif \
merqury.sh ${MERYL_DIR} ${INPUT_FLYE_POLISHED_ASSEMBLY} ${INPUT_CANU_POLISHED_ASSEMBLY} ${output_prefix}


