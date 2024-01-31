#!/usr/bin/env bash

#SBATCH --cpus-per-task=10
#SBATCH --mem=10G
#SBATCH --time=00:10:00
#SBATCH --job-name=Phylogeny
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/13_phylogeny_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/13_phylogeny_%j.e

source1=$1
source2=$2
destination=$3

module load UHTS/Analysis/SeqKit/0.13.2
module load SequenceAnalysis/MultipleSequenceAlignment/clustal-omega/1.2.4
module load Phylogeny/FastTree/2.1.10


# Prepare aliases to use later
COPIA=${source1}/Copia.fasta.rexdb-plant.dom.faa
GYPSY=${source1}/Gypsy.fasta.rexdb-plant.dom.faa

# Make directory to store the results and go to it
mkdir -p ${destination}/11_Phylogeny
cd ${destination}/11_Phylogeny

# Extract and make a list of RT protein sequences
grep Ty1-RT $COPIA > Copia_list
grep Ty3-RT $GYPSY > Gypsy_list

#remove ">" from the header
sed -i 's/>//' Copia_list
sed -i 's/>//' Gypsy_list

#remove all characters following "empty space" from the header
sed -i 's/ .\+//' Copia_list
sed -i 's/ .\+//' Gypsy_list

#remove all characters following "empty space" from the header
#sed -i 's/ .\+//' Copia_list 
#sed -i 's/ .\+//' Gypsy_list

# search for sequences in the specified input file that match the patterns listed in the input list
# -f : To specify the input containing the patterns to search for.
# -o : To specify the output file where the matching sequences will be saved.
seqkit grep -f Copia_list $COPIA -o Copia_RT.fasta
seqkit grep -f Gypsy_list $GYPSY -o Gypsy_RT.fasta

# Shorten the identifiers of RT sequences
sed -i 's/|.\+//' Copia_RT.fasta #remove all characters following "|"
sed -i 's/|.\+//' Gypsy_RT.fasta #remove all characters following "|"

# Use Clustal Omega software for multiple sequence alignment.
# -i: To specify the input file containing nucleotide sequences
# -o: To specify the output file containing the aligned protein sequences.
clustalo -i Copia_RT.fasta -o Copia_protein_alignment.fasta
clustalo -i Gypsy_RT.fasta -o Gypsy_protein_alignment.fasta

# Use FastTree software for inferring approximately-maximum-likelihood phylogenetic trees from alignments of protein sequences.
FastTree -out Copia_protein_alignment.tree Copia_protein_alignment.fasta
FastTree -out Gypsy_protein_alignment.tree Gypsy_protein_alignment.fasta


# Initialize an array called SUPERFAMILIES with two elements: "Copia" and "Gypsy"
SUPERFAMILIES=("Copia" "Gypsy")

# start a loop that iterates through each element in the SUPERFAMILIES array
for SUPERFAMILY in "${SUPERFAMILIES[@]}"
do
    # Construct class file name by concatenating the value of the source variable with the current SUPERFAMILY element and the specified file extension.
    CLASS_FILE=${source1}/${SUPERFAMILY}.fasta.rexdb-plant.cls.tsv
     
    # Use AWK to process the file. Set the field separator to tab ('\t'), skip the first row (header), extract the fourth column, sort the output, remove duplicate lines, and append the unique values to a file named "${SUPERFAMILY}_uniq_clades.txt".
    awk -F '\t' 'NR>1 {print $4}' ${CLASS_FILE} | sort | uniq > ${SUPERFAMILY}_uniq_clades.txt
  


    # Preparation steps to highlight TE clades
        # =======================================================================================

        # DATASET_COLORSTRIP follows the pattern: TE_family                 hex_color_code  Clade
        #                                         TE_00000525_INT#LTR/Gypsy #FF0000         Reina


    # Construct the path to a file named ${SUPERFAMILY}_RT.fasta in the current directory and assign it to the variable RT_PROT.
    RT_PROT=./${SUPERFAMILY}_RT.fasta
    # Create a template for the color information for the tree. These are only a few options. Other options can be cahanged in the itol website
    echo -e "DATASET_COLORSTRIP\nSEPARATOR SPACE\nDATASET_LABEL label1\nCOLOR #ff0000\nCOLOR_BRANCHES 1\nSTRIP_WIDTH 25\nSHOW_STRIP_LABELS 1\nSTRIP_LABEL_SIZE_FACTOR 1.5\nDATA" > ${SUPERFAMILY}_dataset_color_strip.txt
    echo -e "DATASET_SIMPLEBAR\nSEPARATOR COMMA\nDATASET_LABEL,label 1\nDATA" > ${SUPERFAMILY}_dataset_simplebar.txt

    # Construct the path to a file named ${SUPERFAMILY}_dataset_color_strip.txt in the current directory and assign it to the variable DATASET_COLORSTRIP
    
    DATASET_COLORSTRIP=./${SUPERFAMILY}_dataset_color_strip.txt
    # Construct the path to a file named ${SUPERFAMILY}_dataset_simplebar.txt in the current directory and assign it to the variable DATASET_SIMPLEBAR.
    DATASET_SIMPLEBAR=./${SUPERFAMILY}_dataset_simplebar.txt

    # Declare an associative array named clade_color. Associative arrays allow you to create key-value pairs similar to a dictionary.
    declare -A clade_color 

    # Use awk command to process data and populate a file with color-coded information based on certain conditions.
    
    # BEGIN block :clade_color is initialized with key-value pairs. Each key represents a clade, and the corresponding value is a color code.
    # Main block: processes the input data from the ${CLASS_FILE} file.
    # For each record in the input file, it prints the first field, the color corresponding to the clade (retrieved from the clade_color array using the fourth field as the key), and the clade itself.
    # >> ${DATASET_COLORSTRIP}: The output of the awk command is appended to the file specified by the variable ${DATASET_COLORSTRIP}.

    awk 'BEGIN{
        clade_color["Ale"]="#003f5c"
        clade_color["TAR"]="#2f4b7c"
        clade_color["Angela"]="#665191"
        clade_color["Bianca"]="#a05195"
        clade_color["Ikeros"]="#d45087"
        clade_color["Ivana"]="#f95d6a"
        clade_color["SIRE"]="#ff7c43"
        clade_color["Tork"]="#ffa600"
        clade_color["Athila"]="#003f5c"
        clade_color["CRM"]="#444e86"
        clade_color["Reina"]="#955196"
        clade_color["Retand"]="#dd5182"
        clade_color["Tekay"]="#ff6e54"
        clade_color["mixture"]="#ffa600"
    }{
        print $1,clade_color[$4],$4
    }' ${CLASS_FILE} >> ${DATASET_COLORSTRIP} 

    # Preparation steps to annotate the tree with the abundance (number of TE copies) of each TE families
    # =======================================================================================
 
    # The ${SUPERFAMILY}_RT.fasta file must be used instead of ${SUPERFAMILY}.fa.rexdb-plant.cls.tsv. This is because the former contains classifications for all TEs/LTR-RTs from TEsorter, not just those with the specific target RT protein sequences (Ty1-RT in Copia and Ty3-RT in Gypsy), which is the case in ${SUPERFAMILY}_RT.fasta.

    # The specified file ${RT_PROT} will be scanned for lines containing the pattern "TE_" followed by a minimum of 8 digits and ending with "_INT". Only the matching portions of the lines will be stored in the file "TE_IDs.txt". As a result, this file will contain the TE IDs specific to the superfamily that had the intended RT protein sequence (Ty1-RT in Copia and Ty3-RT in Gypsy).

    grep -Eo "TE_[0-9]{8,}_INT" ${RT_PROT} > ${SUPERFAMILY}_TE_IDs.txt

    # Retrieve the count of each TE in TE_IDs.txt from the EDTA summary, then store the count of each TE in the DATASET_SIMPLEBAR for iTOL annotation.
    awk 'NR==FNR{a[$1]; next} $1 in a {print $1, $2}' ${SUPERFAMILY}_TE_IDs.txt ${source2}/Flye_polished.fasta.mod.EDTA.TEanno.sum | \
    awk -v VAR=${SUPERFAMILY} '{print $1 "#LTR/" VAR "," $2}' \
    >> ${DATASET_SIMPLEBAR}
done


