#!/usr/bin/env bash

#SBATCH --cpus-per-task=20
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --job-name=TEsorter
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/11_TEsorter_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/11_TEsorter_%j.e


# Define input and output directories
# User needs to provide path to the project directory which also contains all the polished genome assemblies i.e., source
# User also needs to provide path to the destination folder where output data should be deposited i.e., destination
# Example: 11_TE_Sorter.sh </path/to/source/> </path/to/destination>
source=$1
destination=$2

# Set the variable REF_GEN to the directory path to the reference genome and other associated files and tools 
# Change this depending on where the reference genome and associated files and tools are.
REF_GEN=/data/courses/assembly-annotation-course

# Prepare aliases to use later. Done for convenience.
EDTA_DIR=${source}/analysis/08_EDTA


# Load required module(s)
module load UHTS/Analysis/SeqKit/0.13.2

# Make a directory to store the TE sorter analysis results and go to it
mkdir -p ${destination}/09_TEsorter
cd ${destination}/09_TEsorter

# use cat to concatenate the contents of the specified file, pipes the output to seqkit grep to extract sequences matching the pattern *<pattern>*, and then redirects the output to a new file named <my_file_name.fasta>.
cat ${EDTA_DIR}/Flye_polished.fasta.mod.EDTA.TElib.fa | seqkit grep -r -p ^*Copia* > Copia.fasta
cat ${EDTA_DIR}/Flye_polished.fasta.mod.EDTA.TElib.fa | seqkit grep -r -p ^*Gypsy* > Gypsy.fasta
cat ${REF_GEN}/Brassicaceae_repbase_all_march2019.fasta | seqkit grep -r -p ^*Copia* > Brassicaceae_copia.fasta
cat ${REF_GEN}/Brassicaceae_repbase_all_march2019.fasta | seqkit grep -r -p ^*Gypsy* > Brassicaceae_gypsy.fasta

# Execute TEsorter Tool using Singularity

# singularity exec: used to run a command within a Singularity container
# --bind: flag used to bind mount directories from the host system into the Singularity container. In this case, it binds the $REF_GEN and $source directories into the container.
# ${REF_GEN}/containers2/TEsorter_1.3.0.sif TEsorter: to provide path to the TEsorter Singularity container
# -db: Specify the database to be used by the TEsorter tool for the analysis of transposable elements (TEs)
# -p: Specify 20 threads for multi-processing.

# Use Singularity to execute the TEsorter tool within the specified container, providing the input file <my_genome_assembly.fasta>, using the "rexdb-plant" database, and specifying 20 threads for processing.

singularity exec \
--bind ${REF_GEN} \
--bind ${source} \
${REF_GEN}/containers2/TEsorter_1.3.0.sif \
TEsorter Copia.fasta -db rexdb-plant -p 20

singularity exec \
--bind ${REF_GEN} \
--bind ${source} \
${REF_GEN}/containers2/TEsorter_1.3.0.sif \
TEsorter Gypsy.fasta -db rexdb-plant -p 20

singularity exec \
--bind ${REF_GEN} \
--bind ${source} \
${REF_GEN}/containers2/TEsorter_1.3.0.sif \
TEsorter Brassicaceae_copia.fasta -db rexdb-plant -p 20

singularity exec \
--bind ${REF_GEN} \
--bind ${source} \
${REF_GEN}/containers2/TEsorter_1.3.0.sif \
TEsorter Brassicaceae_gypsy.fasta -db rexdb-plant -p 20

