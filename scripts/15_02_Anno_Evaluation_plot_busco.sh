#!/usr/bin/env bash

#SBATCH --time=01:00:00
#SBATCH --mem=2G
#SBATCH --cpus-per-task=1
#SBATCH --job-name=busco_plot
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/06_evaluation_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/06_evaluation_%j.e
#SBATCH --partition=pall

# Load the required module(s)
module add UHTS/Analysis/busco/4.1.4;

# Define input and output directories
# User needs to provide path to the input directory which contains all the results of all the BUSCO analysis for all accessions i.e., SOURCE
# User also needs to provide path to the destination folder where output data should be deposited i.e., DESTINATION
# User also needs to provide path to the 06_b_generate_busco_plots.py script i.e.,SCRIPT
# Example: 15_02_Anno_Evaluation_plot_busco.sh </path/to/source/> </path/to/destination> </path/to/script>

SOURCE=$1
DESTINATION=$2
SCRIPT=$3
# Define the REF directory where all the BUSCO analysis files from all the participants are.
REF=/data/courses/assembly-annotation-course/CDS_annotation/busco

mkdir -p ${DESTINATION}/BUSCO_PLOTS
cd ${DESTINATION}/BUSCO_PLOTS

cp ${SOURCE}/*.txt .

# script will generate bar charts to summarise BUSCO runs for side-by-side comparisons

#module load UHTS/Analysis/busco/4.1.4

# Generate plots and R script from BUSCO results
python3 ${SCRIPT}/06_b_generate_busco_plots.py -wd .
