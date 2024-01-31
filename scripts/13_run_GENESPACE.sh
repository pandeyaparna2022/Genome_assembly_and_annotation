#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=20:00:00
#SBATCH --job-name=GENESPACE
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/13_run_GENESPACE_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/13_run_GENESPACE_%j.e
#SBATCH --partition=pall


script_dir=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/scripts/friboutg
working_dir=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation
genespace_image=${working_dir}/scripts/friboutg/genespace_1.1.4.sif
genespace_script=${working_dir}/scripts/friboutg/genespace.R


# Run GENESPACE (from a container)

#GENESPACE_IMAGE=${script_dir}/genespace_1.1.4.sif
#GENESPACE_SCRIPT=${script_dir}/genespace.R

apptainer exec \
--bind ${working_dir} \
${genespace_image} Rscript ${genespace_script}

#apptainer exec ${GENESPACE_IMAGE} Rscript ${GENESPACE_SCRIPT}

