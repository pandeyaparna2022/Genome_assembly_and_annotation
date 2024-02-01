#!/usr/bin/env bash

#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --time=20:00:00
#SBATCH --job-name=genesp_bed
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end,fail
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/16_GENESPACE_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/1666666_GENESPACE_%j.e
#SBATCH --partition=pall


module add UHTS/Analysis/SeqKit/0.13.2

# Define input and output directories
# User needs to provide path to the entire assembly directory as we need to bind this to the container, allowing the container to access files and directories within the directory.i.e., PROJECTDIR
# User also needs to provide path to the destination folder where output data should be deposited i.e., DESTINATION
# User also needs to provide path to the genespace.R script i.e.,SCRIPT


DESTINATION=$1
SCRIPTDIR=$2
PROJECTDIR=$3
genespace_image=${SCRIPTDIR}/genespace_1.1.4.sif
genespace_script=${SCRIPTDIR}/genespace.R


# Define path to the reference directory where reference files are. 
REF=/data/courses/assembly-annotation-course/CDS_annotation/Genespace

# Define and create output directories and sub-directories within the destination for properly storing the results
OUTPUTDIR=${DESTINATION}/14_comparative_genomics
mkdir -p ${OUTPUTDIR}
BEDDIR=${OUTPUTDIR}/bed
mkdir -p ${BEDDIR}
PEPTIDEDIR=${OUTPUTDIR}/peptide
mkdir -p ${PEPTIDEDIR}

# Loop over all datasets (only consider files, not folders)
for gff_file_path in ${REF}/*noseq*renamed*gff; do
if [[ -f ${gff_file_path} ]]; then

    # Define the base name of the files (accession/dataset)
    gff_file=$(basename ${gff_file_path})
    base=${gff_file%.all*}
    
    # Input gff
    gff=${gff_file_path}
    fasta=${REF}/${base}*proteins*renamed*fasta

    # Intermediate output files
    out_contigs=${OUTPUTDIR}/${base}_longest_contigs.txt
    out_gene_IDs=${OUTPUTDIR}/${base}_gene_IDs.txt
    # Output bed
    out_bed=${BEDDIR}/${base}.bed
    # Output peptide
    out_peptide=${PEPTIDEDIR}/${base}.fa

    # Filter the gff for the third field ($3) "type" == "contig"; sort them in reverse order (-r) based on the fifth field ($5) "width" numerically (-n)
    # cat ${gff} | awk '$3=="contig"' | sort -t $'\t' -k5 -n -r | head -n 10 > ${out_contigs}
    cat ${gff} | awk '$3=="contig"' | sort -t $'\t' -k5 -n -r | cut -f 1,4,5,9 | sed 's/ID=//' | sed 's/;.\+//' | head -n 10 > ${out_contigs}

    # -t $'\t': Specifies the field separator as a tab character (\t).
    # -k5: Sorts based on the fifth field ($5)
    # -n: sorts numerically (not alphabetically).
    # -r: Sorts the lines in reverse order.

    #Create bed file
    cat ${gff} | awk '$3=="mRNA"' | cut -f 1,4,5,9 | sed 's/ID=//' | sed 's/;.\+//' | grep -w -f <(cut -f1 ${out_contigs}) > ${out_bed}

    #Get the gene IDs
    cut -f4 ${out_bed} > ${out_gene_IDs}

    #Create fasta file
    cat ${fasta} | seqkit grep -r -f ${out_gene_IDs} | seqkit seq -i > ${out_peptide}

fi
done

# Copy the reference files to the directory for genespace
cp ${REF}/TAIR10.bed ${BEDDIR} 
cp ${REF}/TAIR10.fa ${PEPTIDEDIR}

# Run GENESPACE (from a container)
apptainer exec \
--bind ${PROJECTDIR} \
${genespace_image} Rscript ${genespace_script}

