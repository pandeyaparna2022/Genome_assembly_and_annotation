#!/usr/bin/env bash

#SBATCH --cpus-per-task=10
#SBATCH --mem=30G
#SBATCH --time=10:00:00
#SBATCH --job-name=TE_dating
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/12_TE_dating_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/12_TE_dating_%j.e


# Define input and output directories
# User needs to provide path to the input directory which contains EDTA analysis results i.e., source
# User needs to provide the path to the script directory where parseRM.pl file is i.e., script_dir
# User also needs to provide path to the destination folder where output data should be deposited i.e., destination
# Example: 12_TE_dating.sh </path/to/source/> </path/to/script/dir/> </path/to/destination>
source=$1
script_dir=$2
destination=$3

# Make a directory to store the phylogeny analysis results and go to it
mkdir -p ${destination}/10_TE_dating
cd ${destination}/10_TE_dating


##-------------------------------------------------------------------------------
## parseRM
## https://github.com/4ureliek/Parsing-RepeatMasker-Outputs
## parseRM.pl is obtained from here.
##-------------------------------------------------------------------------------

# Activate bioperl Conda environment. This allows the user to work within an isolated environment where the specific Perl and BioPerl packages and dependencies required for bioinformatics and computational biology tasks are available.

# Load required module(s)
module load Conda/miniconda/latest # load conda # conda version : 4.10.1
# Prepare the environment for Python # python version : 3.6.13.final.0
eval "$(conda shell.bash hook)" 

# activate conda environment: perl-bioperl, which is needed for parseRM to run correctly
conda activate bioperl

# Invoke the Perl interpreter to execute the "parseRM.pl" script.
# -i: To specify the input file for the script.
# uses -l <max,bin> to split the amount of DNA by bins of % divergence (or My) for each repeat name, family or class (one output for each). In this case: To get the numbers in bins of 1% of divergence to consensus, up to 50%.

INPUT_FILE=${source}/Flye_polished.fasta.mod.EDTA.anno/Flye_polished.fasta.mod.out
cp ${INPUT_FILE} .

perl ${script_dir}/parseRM.pl -i Flye_polished.fasta.mod.out -l 50,1 -v

# Modify the output file $genome.mod.out.landscape.Div.Rname.tab by removing the first and the 3rd line:
Output_file=./Flye_polished.fasta.mod.out.landscape.Div.Rname.tab
sed -i '1d;3d' ${Output_file}

#cp ${Output_file} .

# Deactivate the Conda environment 
conda deactivate

# Load R module if required
module load R/3.6.1;

export OUTPUT_DIR=$(pwd)

# Run R script
# You might need to edit the filename in R scrip if you have used a different output name for EDTA analysis
Rscript ${script_dir}/plot_div.R
