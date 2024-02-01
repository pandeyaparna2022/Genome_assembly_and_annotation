#!/usr/bin/env bash
#SBATCH --time=1-00:00:00
#SBATCH --mem=48G
#SBATCH --cpus-per-task=4
#SBATCH --job-name=Polishing_genome_assembly
#SBATCH --mail-user=aparna.pandey@students.unibe.ch
#SBATCH --mail-type=begin,end
#SBATCH --output=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/05_genome_assembly_polishing_%j.o
#SBATCH --error=/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/logs/05_genome_assembly_polishing_%j.e

# define input and output directories
# User needs to provide input path to the main directory where all the genome assemblies (this drectory contains sub-directories with Flye and Canu assemblies ) i.e., source1
# User also needs to input the path to the directory with Illumina sequencing reads to be used for polishing i.e., source2
# Finally User needs to input the path to the destination folder where output data should be deposited i.e., destination

#example:05_genome_assembly_polishing.sh </path/to/source1/> </path/to/source2> </path/to/destination>

source1=$1
source2=$2
destination=$3

# Load the required module(s)
module add UHTS/Aligner/bowtie2/2.3.4.1;
module add UHTS/Analysis/samtools/1.10;

# Define two different inputs types: one for Flye assembly and one for Canu assembly

INPUT_FLYE=${source1}/Flye_genome_assembly
INPUT_CANU=${source1}/Canu_genome_assembly

#Change directory yo the destination directory
cd ${destination}

# Make a directory to store the output data. -p option is used to avoid an error if a directory of that name already exists. If the directory already exists and output file names match any of the file names in the directory, those files will be overwritten.
mkdir -p 05_Polished_genome_assemblies

# Go to the output directory
cd 05_Polished_genome_assemblies

# Make a directory to store indices.
mkdir -p indices

# Change diretory to indices directory
cd indices

# Run bowtie2-build
bowtie2-build ${INPUT_FLYE}/*assembly.fasta ./Flye
bowtie2-build ${INPUT_CANU}/*.contigs.fasta ./Canu

# Navigate to the directory created for storing the polished genome assemblies
cd ${destination}/05_Polished_genome_assemblies

# Make a directory to store mapped_bam_files
mkdir -p mapped_bam_files
# Change directory to the directory created to store the mapped mab files
cd mapped_bam_files

# Creates an array of file paths matching the pattern *.fastq.gz in the specified directory
FILES=(${source2}/*.fastq.gz)

# Create a loop that iterates through the FILES array in pairs, reflecting the fact that these are paired-end sequencing files, and assigns FILE1 and FILE2 accordingly. Depending on the organization of your files in the source directory, you may need to adjust this section. In this scenario, the paired-end files are located consecutively, so the loop progresses in intervals of two.

for ((i = 0; i < ${#FILES[@]}; i += 2)); do
    FILE1="${FILES[i]}"
    FILE2="${FILES[i + 1]}"
    # Use the bowtie2 tool with the following parametes to align the sequences in the two files to the indexed reference genome for "Canu" and "Flye".
    # --sensitive-local: This option tells bowtie2 to use a sensitive, end-to-end local alignment mode. This mode is suitable for aligning short reads to longer reference sequences with high sensitivity.
    # --threads 4: This option specifies the number of CPU threads to use for alignment for parallel processing.
    # -x ${destination}/05_Polished_genome_assemblies/indices/Canu or Flye: This specifies the path to the index files for the reference genome "Canu" or "Flye". The -x flag is used to specify the basename of the index files. 
    # -1 ${FILE1} -2 ${FILE2}: These options specify the paired-end input files for the alignment.
    # -S ${name}_mapped.sam: This option specifies the output file where the alignment results will be stored in SAM format. The -S flag is used to specify the output SAM file.
    bowtie2 --sensitive-local --threads 4 -x ${destination}/05_Polished_genome_assemblies/indices/Canu -1 ${FILE1} -2 ${FILE2} -S Canu_mapped.sam
    bowtie2 --sensitive-local --threads 4 -x ${destination}/05_Polished_genome_assemblies/indices/Flye -1 ${FILE1} -2 ${FILE2} -S Flye_mapped.sam 
    done

# Use the samtools command-line tool to convert SAM (Sequence Alignment/Map) files to BAM (binary alignment/map) files
# samtools view: This command transforms SAM files into different formats or can perform operations on SAM files.
# --threads 4: This option specifies the number of CPU threads to use for alignment for parallel processing.
# -bo: These options are used together to specify the output format and file. -b indicates that the output should be in BAM format, and -o specifies the output file.
# ${name}_mapped_unsorted.bam: This is the name of the output BAM file that will be created by the operation.
# ${name}_mapped.sam: This is the input SAM file on which the operation will be performed.
 
samtools view --threads 4 -bo Canu_mapped_unsorted.bam Canu_mapped.sam
samtools view --threads 4 -bo Flye_mapped_unsorted.bam Flye_mapped.sam

# Sort the BAM files
# Create a for loop to iterate through a list of files and perform a sorting operation using the samtools command-line tool.
for x in $(ls -d *_mapped_unsorted.bam);do 
    # samtools sort: This command is used to sort BAM files.
    # -@ 4: Specifies the number of CPU threads to be used for parallel processing.
    # ${x}: Specifies the input BAM file that will be sorted.
    # -o $(basename ${x} _unsorted.bam)_sorted.bam: Specifies the output file name. It uses the basename of the input file, removes the _unsorted.bam suffix, and appends _sorted.bam to create the name for the sorted output file.
    samtools sort -@ 4 ${x} -o $(basename ${x} _unsorted.bam)_sorted.bam;
    done
# Index the sorted BAM files
# Create a for loop to iterate through the list of sorted BAM files and index the files using the samtools command-line.
for x in $(ls -d *_sorted.bam);do 
   # samtools index ${x}: Creates an index file for the specified input BAM file (${x}). The index file has the same name as the input BAM file with the addition of the .bai extension.
    samtools index ${x};
    done

# Use Java runtime environment to execute the Pilon genome assembly improvement tool
# java: This command is used to execute Java programs.
# -Xmx45g: This option sets the maximum memory allocation pool for the Java Virtual Machine (JVM) to 45 gigabytes.
# -jar /mnt/software/UHTS/Analysis/pilon/1.22/bin/pilon-1.22.jar: This specifies the path to the Pilon JAR (Java ARchive) file, which contains the Pilon genome assembly improvement tool.
# --genome ${INPUT_CANU}/*.contigs.fasta: This option specifies the input genome assembly in the form of a wildcard path to the contigs.fasta files generated by Canu
# --genome ${INPUT_FLYE}/*assembly.fasta: This option specifies the input genome assembly in the form of a wildcard path to the fasta file generated by Flye.
# --frags ${name}*_sorgted.bam: This option specifies the input BAM files containing the sorted alignments of reads to the initial genome assembly.
# --output ${name}: This option specifies the prefix for the output files generated by Pilon
# --diploid: This flag indicates that the input genome is diploid, which may affect Pilon's analysis and correction strategies.eg., will eventually affect calling of heterozygous SNPs
# --fix "all": This parameter specifies the type of fixes to apply. In this case, "all" likely indicates that Pilon should attempt to fix all identified issues in the input genome assembly
# --threads 4: This option specifies the number of CPU threads to use for alignment for parallel processing.

java -Xmx45g -jar /mnt/software/UHTS/Analysis/pilon/1.22/bin/pilon-1.22.jar \
--genome ${INPUT_FLYE}/*assembly.fasta --frags Flye*_sorted.bam --output Flye_polished --diploid --fix "all" --threads 4

java -Xmx45g -jar /mnt/software/UHTS/Analysis/pilon/1.22/bin/pilon-1.22.jar \
--genome ${INPUT_CANU}/*.contigs.fasta --frags Canu*_sorted.bam --output Canu_polished --diploid --fix "all" --threads 4
