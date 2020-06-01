#!/bin/bash

# Job name:
#SBATCH --job-name=download
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit: ### Only toook 37 min!
#SBATCH --time=00-01:01:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=254M


## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default

## Prepare input files
workdir=/cluster/projects/nn9383k/ivar
cd $workdir

## Copying file
srun wget https://1001genomes.org/data/GMI-MPI/releases/v3.1/1001genomes_snp-short-indel_with_tair10_only_ACGTN.vcf.gz
