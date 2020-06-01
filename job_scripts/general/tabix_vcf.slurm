#!/bin/bash

# Job name:
#SBATCH --job-name=tabix_vcf
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-12:11:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=256M

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default

## Prepare input files
workdir=$USERWORK/dog
cd $workdir

## Do:
srun tabix -p vcf all_without_genotype_info_numeric.vcf.gz

