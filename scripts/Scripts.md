# Information about Scripts

These codes are written for setting up a genome assembly and annotation pipeline for data analysis. Please make sure you have access to the raw sequencing data and and additional files prior to data analysis.

# Additional Files
-	file containing one sequence per locus corresponding to representative gene model sequence for A. thaliana. The representative gene model is defined as the model that codes for the longest CDS at each locus

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
All shell scripts include SBATCH options at the start to enable submission to the SLURM workload manager, which helps alleviate the computational load on the head node of the HPC cluster.

Attention: Please note that the file names may vary. If they do, you may need to modify the script where the file name is used. Review the code and comments for a clearer understanding of the provided scripts.

Please change path to the log outputs prior to running the code.
Please change the email address to receive notifications. 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Additional information:
- All the scripts require at least 1 input path and 1 output path indicating the location of the input file to be processed and the location of the output file respectively.
- Some may require additional paths depending on whether they require additional inputs that are not present in the first input path. 
- The scripts create subfolders withing the specified output folder with intuitive names to store results of analysis. 
- A detailed description of necessary paths for the script is given in the beginning of every script. 
- Run the scripts in the order of their numbering .
- The script can be run as follows:
example.sh <path/to/input/files/> <path/to/output/files/> …
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
# Recommendation 
Prior to running the code it is suggested to have the following structured layout for the data and results. This is not mandatory, but it is advised. 
- Create a folder for the project named Genome_assembly_and_annotation.
- Create a directory named Scripts to store all your scripts
- Create a directory called analysis to store all the results from the analysis. 
- Create a directory called logs within analysis to store output and error reports for all the analysis





