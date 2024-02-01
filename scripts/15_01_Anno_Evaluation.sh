#!/usr/bin/env bash

#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=10:00:00
#SBATCH --job-name=eval_maker
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/16_MAKER_eval_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/16_MAKER_eval_%j.e

# Define input and output directories
# User needs to provide path to the input directory which contains MAKER analysis results i.e., SOURCE
# User also needs to provide path to the destination folder where output data should be deposited i.e., DESTINATION
# User also needs to provide path to the blast_visualization.R script i.e.,SCRIPT
# Example: 15_01_Anno_Evaluation.sh </path/to/source/> </path/to/destination> </path/to/SCRIPT>
SOURCE=$1
DESTINATION=$2
SCRIPT=$3
# Define the REF directory where reference files are
REF=/data/courses/assembly-annotation-course/CDS_annotation/MAKER

# Load required module(s)
module add UHTS/Analysis/busco/4.1.4
module add Blast/ncbi-blast/2.10.1+
module add SequenceAnalysis/GenePrediction/maker/2.31.9

# Make the required directories to store different evaluations
mkdir -p ${DESTINATION}/13_Annotation_Evaluation/BUSCO_evaluation
mkdir -p ${DESTINATION}/13_Annotation_Evaluation/UniProt_evaluation

# Start with BUSCO evaluation
# Move to the folder for BUSCO evaluation
cd ${DESTINATION}/13_Annotation_Evaluation/BUSCO_evaluation

# Specify the assembly to use
assembly=${SOURCE}/run_mpi.maker.output/run_mpi.all.maker.proteins.renamed.fasta

#Make a copy of the augustus config directory to a location where you have write permission
cp -r /software/SequenceAnalysis/GenePrediction/augustus/3.3.3.1/config augustus_config
export AUGUSTUS_CONFIG_PATH=./augustus_config

#Run busco to assess the quality of the assemblies

#-i: Input sequence file in FASTA format. Can be an assembled genome or transcriptome (DNA), or protein sequences from an annotated gene set.
#-l: Specify the name of the BUSCO lineage to be used.
#-o: defines the folder that will contain all results, logs, and intermediate data
#-m: Specify which BUSCO analysis mode to run, genome, proteins, transcriptome
#-c: Specify the number (N=integer) of threads/cores to use

busco -i ${assembly} -l brassicales_odb10 -o BUSCO -m proteins -c 8
        
#Remove the augustus config directory again
rm -r ./augustus_config


# Move to the directory to store results of evaluation based on uniprot
cd ${DESTINATION}/13_Annotation_Evaluation/UniProt_evaluation

# Make a directory to store the blast database
mkdir -p blastdb

# Align protein against UniProt database
# Create a BLAST database from FASTA files
# -in ${course_dir}/uniprot_viridiplantae_reviewed.fa: Specify the input file containing the sequences for creating the BLAST database.
# -dbtype prot: Specify the type of sequences in the input file as protein sequences.
# -out ${blastdb_dir}/uniprot-plant_reviewed: Specify the path and name for the resulting BLAST database.
makeblastdb -in ${REF}/uniprot_viridiplantae_reviewed.fa -dbtype prot -out ./blastdb/uniprot-plant_reviewed

# -query ${assembly}: To specify the input file containing the query sequences for the BLAST search.
# -db ./blastdb/uniprot-plant_reviewed: To specify the path to the BLAST database to be used for the search.
# -num_threads 30: To specify the number of threads (parallel processes) to be used for the BLAST search.
# -outfmt 6: To specify the output format for the BLAST results as tabular format.
# -evalue 1e-10: To specify the maximum expected value (E-value) threshold for reporting matches in the BLAST results.
# -out blastp.out: To specify the path and name for the output file containing the BLAST results.

blastp -query ${assembly} -db ./blastdb/uniprot-plant_reviewed -num_threads 30 -outfmt 6 -evalue 1e-10 -out blastp.out

# blastp was run with -outfmt 6, meaning the output file has the format:
# query_id      subject_id      per_identity    aln_length      mismatches      gap_openings    q_start q_end   s_start s_end   e-value bit_score

# In this format…

# query_id is the FASTA header of the sequence being searched against the database (the query sequence).
# subject_id is the FASTA header of the sequence in the database that the query sequence has been aligned to (the subject sequence).
# per_identity is the percentage identity- the extent to which the query and subject sequences have the same residues at the same positions.
# aln_length is the alignment length.
# mismatches is the number of mismatches.
# gap_openings is the number of gap openings in the alignment.
# q_start is the start of the alignment in the query sequence.
# q_end is the end of the alignment in the query sequence.
# s_start is the start of the alignment in the subject sequence.
# s_end is the end of the alignment in the subject sequence.
# e_value is the expect value (E-value) for the alignment.
# bit_score is the bit-score of the alignment.
# from: https://rnnh.github.io/bioinfo-notebook/docs/blast.html

# cut -f 1 w8_Annotation_QC/blastp_output | sort -u | wc -l
# cut -f 1 w8_Annotation_QC/blastp_filtered.tsv | sort -u | wc -l


# Use the grep command to search for and extract specific patterns from the ${PROT} file with the following parameters
# -Eo "run_mpi_[0-9]{6,}-RA": Specify the extended regular expression pattern to be matched in the input file.
# ${assembly}: Specify the input file in which the pattern will be searched.
# > annotated_proteins.txt: Redirects the output of the grep command to a file named annotated_proteins.txt.

grep -Eo "run_mpi_[0-9]{6,}-RA" ${assembly} > annotated_proteins.txt

# check if the value in the third column (which represents the percentage identity) is greater than or equal to 98. If it is, the corresponding line is printed to the output file.
awk '$3 >= 98' blastp.out > blastp_filtered.tsv

# Export the working directory
export WORKDIR=$(pwd)
# Load the R module
module load R/latest

# --no-save: Prevent R from saving the workspace at the end of the session. 
# --no-restore: Prevent R from restoring the previous workspace at the beginning of the session.
Rscript --no-save --no-restore ${SCRIPT}/blast_visualization.R
