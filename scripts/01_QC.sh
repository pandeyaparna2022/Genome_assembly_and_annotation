#!/usr/bin/env bash
#SBATCH --job-name="QC"
#SBATCH --nodes=1
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --cpus-per-task=8
#SBATCH --time=00:50:00
#SBATCH --mem=8G
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/01_QC_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/01_QC_%j.e


#QC analysis

#User needs to input path to the directory where the input data (sequencing reads) is (source) and the path to the directory where output data should go (destination) when running the script with sbatch
#example: sbatch 01_QC.sh </path/to/source/> </path/to/destination>

source=$1
destination=$2

#load required modules
module load UHTS/Quality_control/fastqc/0.11.9
module load UHTS/Analysis/MultiQC/1.8

#change directory to the destination/result directory 
cd ${destination}

# Make a directory to store QC data. -p option is used to avoid an error if a directory of that name already exists. If the directory already exists and output file names match any of the file names in the directory, those files will be overwritten.
mkdir -p 01_QC

cd 01_QC

#Create a link to the raw files, in the current directory for qc analysis
#code: for loop that loops over all the files with .fsatq.gz extension in the given path and creates individual links for all the .fastq.gz files in the current directory
# Edit this section if all your files are in the same directory and/or you do not wish to make the symbolic links 

for file in ${source}/Illumina/*.fastq.gz; do ln -s "$file" . ; done
for file in ${source}/pacbio/*.fastq.gz; do ln -s "$file" . ; done
for file in ${source}/RNAseq/*.fastq.gz; do ln -s "$file" . ; done

# Code: Iterates over each file with the extension ".fastq.gz" and runs the fastqc command with the -t 6 option to specify the number of threads for parallel processing and the file as an argument to analyze the quality of the FASTQ data
# After running fastqc for a file, it removes the file using the rm command

for i in `ls -1 *.fastq.gz`;
do fastqc -t 6 $i; rm $i;
done

# multiqc command is used to generate a combined multi-sample report by scanning the current directory (.) for analysis results from tools like FastQC. This is optional.

multiqc .

# Remove the symbolic links after performing QC
#find ./ -type l -exec rm {} +

#You can now download the html files on your local computer to assess the quality of raw reads
# You can edit the following command and replace the host server, source_file_path and destination_file_path to do so.
# -r is used to recrsively download the files and *.html is used to download all files with .html extension

# scp -r user@host:source_file_path/*.html destination_file_path

