#!/usr/bin/env bash

#SBATCH --time=00:10:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=MAKER_Prep
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/14_01_MAKER_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/14_01_MAKER_%j.e
#SBATCH --partition=pall

# User needs to provide the destination for the output of MAKER
# Example: 114_01_Maker.sh </path/to/destination>
destination=$1

# Set the variable REF to the directory path where associated files and tools are.
REF=/data/courses/assembly-annotation-course

# Make a directory for the output and move there
mkdir -p ${destination}/12_Maker 
cd ${destination}/12_Maker


# MAKER can't find the files that were specified in maker_opts.ctl even when specifying the full path.
# To avoid this problem,when running a container enable access to files or directories on the host system from the container.
# Mount a filesystem within the container. Give meaningful names to the path under which files from the host will be accessible within the container  and use these paths in maker_opts.ctl to point MAKER in the right direction.

# Run this script to generate the control files using the specified MAKER version. Then, follow the provided instructions to edit the control files using the mounted paths from the container as detailed in 14_02_Maker.sh, and finally execute the MAKER script.

# 1) Create control files(templates)
singularity exec \
--bind ${SCRATCH} \
--bind ${REF} \
--bind ${destination}/12_Maker \
${REF}/containers2/MAKER_3.01.03.sif \
maker -CTL

