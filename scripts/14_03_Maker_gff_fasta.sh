#!/usr/bin/env bash

#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --time=20:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --job-name=maker_gff_fasta
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/15_create_fasta_gff_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/15_create_fasta_gff_%j.e

# Load required module(s)
module load SequenceAnalysis/GenePrediction/maker/2.31.9;

# set the environment variable TMPDIR to the value of the SCRATCH variable. This is done to define the temporary directory where various programs and scripts can store temporary files and data during their execution.
export TMPDIR=$SCRATCH

# Define input and output directories
SOURCE=$1
DESTINATION=$2

cd ${DESTINATION}/12_Maker

# Sets the variables base and output_tag
# Then change the current directory to the directory specified by the ${base}.maker.output variable.

base="run_mpi"
cd ${base}.maker.output

# merge GFF files using the specified master datastore index log and output the merged GFF file with the name ${output_tag}.all.maker.gf
gff3_merge -d ${base}_master_datastore_index.log -o ${base}.all.maker.gff
# merge GFF files using the specified master datastore index log, excluding sequence information, and output the merged GFF file with the name ${output_tag}.all.maker.noseq.gff.
gff3_merge -d ${base}_master_datastore_index.log -n -o ${base}.all.maker.noseq.gff
# merge FASTA files using the specified master datastore index log and output the merged FASTA file with the name ${output_tag}.
fasta_merge -d ${base}_master_datastore_index.log -o ${base}

# Set the variables protein, transcript, gff, and prefix to specific values
protein=${base}.all.maker.proteins
transcript=${base}.all.maker.transcripts
gff=${base}.all.maker.noseq
prefix=${base}_

# Copy the following files to new files with renamed filenames
cp ${gff}.gff ${gff}.renamed.gff
cp ${protein}.fasta ${protein}.renamed.fasta
cp ${transcript}.fasta ${transcript}.renamed.fasta

# Use the maker_map_ids tool to build shorter IDs/names for MAKER genes and transcripts following the NCBI suggested naming format.
# --prefix : To specify the prefix to be used for the new IDs/names,
# --justify: To specify the length of the new IDs/names.
# The specified prefix and justification value are used to process the ${gff}.renamed.gff file to generate an output file named ${base}.id.map.
maker_map_ids --prefix $prefix --justify 7 ${gff}.renamed.gff > ${base}.id.map
# Map the IDs in the ${gff}.renamed.gff file using the ${base}.id.map file.
map_gff_ids ${base}.id.map ${gff}.renamed.gff
# Map the IDs in the ${protein}.renamed.fasta file using the ${base}.id.map file
map_fasta_ids ${base}.id.map ${protein}.renamed.fasta
# Map the IDs in the ${transcript}.renamed.fasta file using the ${base}.id.map file
map_fasta_ids ${base}.id.map ${transcript}.renamed.fasta


