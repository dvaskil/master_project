#!/bin/bash

# Description: 
# Cutting samples out of vcf for arabidopsis and dog.
#
# Job name:
#SBATCH --job-name=cut_samples_vcf
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-13:10:00
#
## Run times: 
## Arabidopis: 2t50min
## Dog: 11t
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=256M

# Description:
# Job script for cutting out samples from a  multi-sample vcf

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default
module load BCFtools/1.9-foss-2018b

## Parameters
workdir=/cluster/projects/nn9383k/eskil/arabidopsis/data_files/vcfs
cd $workdir

## BEGIN:
bcftools view -s ^801,1622,2081,6020,9095 1001genomes_snp-short-indel_with_tair10_only_ACGTN.vcf.gz | bcftools view -q 0.000001 | cut -f 1-9 | bgzip > ar_cut_GT.vcf.gz
