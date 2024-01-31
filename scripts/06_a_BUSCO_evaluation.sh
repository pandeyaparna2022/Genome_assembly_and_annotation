#!/usr/bin/env bash

#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --time=1-00:00:00
#SBATCH --job-name=BUSCO
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/06_BUSCO_evaluation_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/06_BUSCO_evaluation_%j.e

# define input and output directories
# User needs to provide path to the directory containing all the unpolished genome assemblies (this drectory contains sub-directories with Flye and Canu assemblies ) i.e., source1
# User also needs to provide path to the directory containing polished genome assemblies i.e., source2
# Similarly User also needs to provide the directory containing transcriptome assemly i.e., source3
# User needs to provide path to the destination folder where output data should be deposited i.e., destination
# Finally User needs to provid the path to the scrip directory which contains the .py file to generate plots to compare the BUSCO evaluations i.e., scripts

#example: 06_BUSCO_evaluation.sh </path/to/source1/> </path/to/source2> </path/to/source3> </path/to/destination> </path/to/scripts>

source1=$1
source2=$2
source3=$3
destination=$4
script=$5

# Define five different inputs types: one each for unpolished and polished Flye and Canu assemblies and one for transcriptome assembly

INPUT_FLYE_UNPOLISHED=${source1}/Flye_genome_assembly
INPUT_CANU_UNPOLISHED=${source1}/Canu_genome_assembly
INPUT_FLYE_POLISHED=${source2}/mapped_bam_files
INPUT_CANU_POLISHED=${source2}/mapped_bam_files
INPUT_TRANSCRIPTOME_ASSEMBLY=${source3}

# Load the required module(s)
module add UHTS/Analysis/busco/4.1.4;

# Change directory yo the destination directory
cd ${destination}

# Create a directory for assembly evaluation
mkdir -p 06_Assembly_evaluation

# Change directory to the assembly evaluation directory
cd 06_Assembly_evaluation

# Create a directory for BUSCO analysis
mkdir -p BUSCO_Analysis

# Change directory to the BUSCO analysis directory
cd BUSCO_Analysis

# IMPORTANT: to run busco, you must first make a copy of the augustus config directory
#            to a location where you have write permission (e.g. your working dir).
#            You can use the following commands:

# The following command copies the contents of the directory /software/SequenceAnalysis/GenePrediction/augustus/3.3.3.1/config to a new directory named augustus_config. The -r option ensures that the copy is recursive, including all subdirectories and their contents.
cp -r /software/SequenceAnalysis/GenePrediction/augustus/3.3.3.1/config augustus_config
# The following command sets the environment variable AUGUSTUS_CONFIG_PATH to the current directory (./augustus_config). This variable is used by the AUGUSTUS gene prediction program to locate its configuration files and related resources.
export AUGUSTUS_CONFIG_PATH=./augustus_config

# Run BUSCO Analysis with following parameters

# -i ${PATH}/file: Specifies the input file for BUSCO analysis.
# -o prefix: Sets the output prefix for the BUSCO analysis results. The results will be labeled with this prefix.
# --lineage brassicales_odb10: Specifies the lineage dataset to be used for assessing the assembly. In this case, it's the brassicales_odb10 dataset, which contains a set of conserved single-copy orthologous genes specific to the order Brassicales.
# -m genome: Specifies the mode of analysis as "genome," indicating that the input is a genome assembly. 
# -m transcriptome: Specifies the mode of analysis as "transcriptome," indicating that the input is a transcriptome assembly. This mode is specifically designed for assessing the completeness of transcriptome assemblies.
# --cpu 16: Specifies the number of CPU threads to be used for parallel processing.
# -f: Forces the overwrite of existing files in the output directory if present.


# Run BUSCO tool to assess the completeness of unpolished flye and canu genome assemblies 
busco -i ${INPUT_FLYE_UNPOLISHED}/assembly.fasta -o flye_unpolished --lineage brassicales_odb10 -m genome --cpu 16 -f
busco -i ${INPUT_CANU_UNPOLISHED}/Canu_pacbio.contigs.fasta -o canu_unpolished --lineage brassicales_odb10 -m genome --cpu 16 -f

# Run BUSCO tool to assess the completeness of polished flye and canu genome assemblies
busco -i ${INPUT_FLYE_POLISHED}/Flye_polished.fasta -o flye_polished --lineage brassicales_odb10 -m genome --cpu 16 -f
busco -i ${INPUT_CANU_POLISHED}/Canu_polished.fasta -o canu_polished --lineage brassicales_odb10 -m genome --cpu 16 -f

# Run BUSCO tool to assess the completeness of Trinity transcriptome assembly
busco -i ${INPUT_TRANSCRIPTOME_ASSEMBLY}/Trinity.fasta -l brassicales_odb10 -o trinity -m transcriptome --cpu 4 -f

# Remove the augustus config
rm -r ./augustus_config

# Generate bar charts to summarise BUSCO runs for side-by-side comparisons

# make a new directory to store the result and go to that directory
mkdir -p BUSCO_Plots
cd BUSCO_Plots


# Copy all the BUSCO summary files in the same folder 
cp ${destination}/06_Assembly_evaluation/BUSCO_Analysis/flye_unpolished/short_summary.specific.brassicales_odb10.flye_unpolished.txt .
cp ${destination}/06_Assembly_evaluation/BUSCO_Analysis/canu_unpolished/short_summary.specific.brassicales_odb10.canu_unpolished.txt .
cp ${destination}/06_Assembly_evaluation/BUSCO_Analysis/flye_polished/short_summary.specific.brassicales_odb10.flye_polished.txt .
cp ${destination}/06_Assembly_evaluation/BUSCO_Analysis/canu_polished/short_summary.specific.brassicales_odb10.canu_polished.txt .
cp ${destination}/06_Assembly_evaluation/BUSCO_Analysis/trinity/short_summary.specific.brassicales_odb10.trinity.txt .

# Generate plots and R script from BUSCO results
python3 ${script}/06_b_generate_busco_plots.py -wd .

