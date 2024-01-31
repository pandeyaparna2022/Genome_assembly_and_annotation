#!/usr/bin/env bash
#SBATCH --time=12:00:00
#SBATCH --mem=10G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=quast
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/08_quast_evaluation_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/08_quast_evaluation_%j.e
#SBATCH --partition=pall


# define input and output directories
# User needs to provide path to the directory containing all the unpolished genome assemblies (this drectory contains sub-directories with Flye and Canu assemblies ) i.e., source1
# User also needs to provide path to the directory containing polished genome assemblies i.e., source2
# Finally User needs to provide path to the destination folder where output data should be deposited i.e., destination

# example: 08_Quast_evaluation.sh </path/to/source1/> </path/to/source2> </path/to/destination>

source1=$1
source2=$2
destination=$3

# Set the variable REF_GEN to the directory path to the reference genome
# Change this depending on where the reference genome is.
REF_GEN=/data/courses/assembly-annotation-course/references

# Load the required module(s)
module load UHTS/Quality_control/quast/4.6.0

# Define four different inputs types: one each for unpolished and polished Flye and Canu assemblies.

INPUT_FLYE_UNPOLISHED=${source1}/Flye_genome_assembly
INPUT_CANU_UNPOLISHED=${source1}/Canu_genome_assembly
INPUT_FLYE_POLISHED=${source2}/mapped_bam_files
INPUT_CANU_POLISHED=${source2}/mapped_bam_files

# Create a directory for the evaluation results and go to that directory
mkdir -p ${destination}/06_Assembly_evaluation/Quast_Analysis
cd ${destination}/06_Assembly_evaluation/Quast_Analysis

# Create additional directories to store evaluation with reference and evaluation without reference
mkdir -p With_Ref
mkdir -p Without_Ref

# Evaluate genome assembly using QUAST (version 4.6.0)
# Quast tool is used to evaluate the genome assembly with the following parameters/options:

# -o <output_dir>: Specifies the output directory for the evaluation result. The default value is quast_results/results_<date_time>.
# -R <path>: Specifies the reference genome file against which the assembly will be evaluated.
# --labels (or -l) <label,label...>: Provides labels for the assemblies being evaluated. These labels will be used in reports, plots and logs.
# -L: Take assembly names from their parent directory names.
# --features (or -g) <path>: File with genomic feature positions in the reference genome. GFF format, versions 2 and 3 => NOT SUPPORTED by Quast 4.6.0
# --eukaryote (or -e): Indicates that the genome is eukaryotic.
# --large: Indicates genome is large (typically > 100 Mbp). 
# --min-contig 3000: Specifies minimum contig length
# --min-alignment 500: Specifies minimum alignment length
# --extensive-mis-size 7000: Specifies the threshold for extensive misassembly size. Quast refers to this threshold for identifying misassemblies based on the length of the misassembled regions.
# --threads (or -t) <int>: Specifies Maximum number of threads for parallel processing. The default value is 25% of all available CPUs but not less than 1.
# If QUAST fails to determine the number of CPUs, maximum threads number is set to 4.
# --est-ref-size <int>: Specifies sstimated reference genome size (in bp) for computing NGx statistics. This value will be used only if a reference genome file is not specified (see -R option).


# Evaluate genome assembly using QUAST (version 4.6.0)

# python /software/UHTS/Quality_control/quast/4.6.0/quast.py: This code invokes the Quast tool using Python.

# Evaluate the genome assembly with reference
python /software/UHTS/Quality_control/quast/4.6.0/quast.py -R ${REF_GEN}/Arabidopsis_thaliana.TAIR10.dna.toplevel.fa \
-o ./With_Ref -l Flye_unpolished_with_Ref,Flye_polished_with_Ref,Canu_unpolished_with_Ref,Canu_polished_with_Ref ${INPUT_FLYE_UNPOLISHED}/*assembly.fasta ${INPUT_FLYE_POLISHED}/Flye_polished.fasta ${INPUT_CANU_UNPOLISHED}/*contigs.fasta ${INPUT_CANU_POLISHED}/Canu_polished.fasta --eukaryote --min-contig 3000 --min-alignment 500 --extensive-mis-size 7000 --threads 4 

# Evaluate the genome assembly without reference
python /software/UHTS/Quality_control/quast/4.6.0/quast.py -o ./Without_Ref -l Flye_unpolished_without_Ref,Flye_polished_without_Ref,Canu_unpolished_without_Ref,Canu_polished_without_Ref ${INPUT_FLYE_UNPOLISHED}/*assembly.fasta ${INPUT_FLYE_POLISHED}/Flye_polished.fasta ${INPUT_CANU_UNPOLISHED}/*contigs.fasta ${INPUT_CANU_POLISHED}/Canu_polished.fasta --eukaryote --min-contig 3000 --min-alignment 500 --extensive-mis-size 7000 --threads 4 --est-ref-size 133725193





