#!/bin/bash

# Job name:
#SBATCH --job-name=cut_samples_vcf
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-13:10:00
#
## Note: Lasted 2t50min
## Dog 11t
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

## Prepare input files
workdir=/cluster/projects/nn9383k/eskil/dog/raw_files
cd $workdir

## Input parameters
#sample="Pug01,Wolf05,Boxer01"
#vcf_file=all.vcf.gz

## Do:
#bcftools view -s ^Pug01,Wolf05,Boxer01 all.vcf.gz | bcftools view -q 0.000001 -Oz | cut -f 1-9 > all_without_genotype_info.vcf.gz ##Made decrepid .gz

bcftools view -s ^Pug01,Wolf05,Boxer01 all.vcf.gz | bcftools view -q 0.000001 | cut -f 1-9 | bgzip > all_without_genotype_info.vcf.gz # Worked

