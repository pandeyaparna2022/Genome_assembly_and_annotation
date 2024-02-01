#!/usr/bin/env bash

#SBATCH --time=2-20:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=MAKER
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/14_02_MAKER_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/14_02_MAKER_%j.e
#SBATCH --partition=pall

# Load the required module(s)
module load SequenceAnalysis/GenePrediction/maker/2.31.9

# Define output and input directories
# User needs to provide path to the entire assembly directory as we need to bind this to the container, allowing the container to access files and directories within the directory.i.e., HOME
# User also needs to provide path to the destination folder where output data should be deposited i.e., DESTINATION

HOME=$1
DESTINATION=$2
# Set the variable REF to the directory path where associated files and tools are.
REF=/data/courses/assembly-annotation-course

cd ${DESTINATION}/12_Maker

# Run MAKER using singularity


# mpiexec: Used to launch MPI (Message Passing Interface) applications.
# -n 16: Used to specify the number of MPI processes to be launched, in this case, 16 processes.
# singularity exec: Used to execute a command within a Singularity container.
# --bind : Singularity option used to bind a host directory to a directory within the container.
# --bind ${SCRATCH}:/TMP: Used to bind the host directory ${SCRATCH} to the directory /TMP within the container.
# --bind ${REF}: Used to bind the host directory specified by ${REF} to the same path within the container.
# --bind ${REF}/CDS_annotation:/CDS_annotation: Used to bind the host directory ${REF}/CDS_annotation to the directory /CDS_annotation within the container.
# --bind /software:/software: Used to bind the host directory /software to the directory /software within the container.
# --bind ${HOME}:/home: Used to bind the host directory specified by ${HOME} to the directory /home within the container.
# ${REF}/containers2/MAKER_3.01.03.sif: Used to specify the path to the Singularity container image for the MAKER software.
# maker -mpi -base run_mpi -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_exe.ctl: Command to be executed within the Singularity container. It runs the MAKER software with the specified options and control files.

mpiexec -n 16 singularity exec \
--bind ${SCRATCH}:/TMP \
--bind ${REF} \
--bind ${REF}/CDS_annotation:/CDS_annotation \
--bind /software:/software \
--bind ${HOME}:/home \
${REF}/containers2/MAKER_3.01.03.sif \
maker -mpi -base run_mpi -TMP /TMP maker_opts.ctl maker_bopts.ctl maker_exe.ctl
