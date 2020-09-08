#!/bin/bash

# Description: 
# Scrip just in case I manually have to index a vcf.
#
# Job name:
#SBATCH --job-name=tabix_vcf
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-00:05:00
#
# all.vcf.gz for dog: 12:11:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem=256M

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default

export PATH=$PATH:$HOME/install/bin

## Prepare input files
workdir=/cluster/projects/nn9383k/eskil/hg38/simulation_data/hg002
cd $workdir

## Do:
tabix -p vcf hg002_hg38_GIAB_numeric.vcf.gz

