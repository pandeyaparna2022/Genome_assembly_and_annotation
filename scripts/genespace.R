library(ggplot2)
library(GENESPACE)
# clone MCScanX from https://github.com/wyp1125/MCScanX.git
# after cloning eneter the MCScanX folder and type make to Compile MCScanX so there are executables in the folder
# 1) Specify paths to the working directory and MCScanX
wd <- "/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/14_comparative_genomics"
path2mcscanx <- "/data/users/apandey/genome_and_transcriptome_assembly_and_annotation/analysis/MCScanX"
# 2) Run init_genespace to make sure that the input data is OK.
# It also produces the correct directory structure and corresponding paths
# for the GENESPACE run
gpar <- init_genespace(
wd = wd,
path2mcscanx = path2mcscanx)
# 3) Run GENESPACE
out <- run_genespace(gpar, overwrite = T)

