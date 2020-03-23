#!/bin/bash
#
# Description:
# Job script for extracting a vcf from one sample in a multi-sample vcf
#
# Job name:
#SBATCH --job-name=extract_vcf_sample
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
## Note: Lasted 6t15min
#SBATCH --time=00-07:01:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=100M

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default
module load BCFtools/1.9-foss-2018b

## Prepare input files
workdir=/cluster/projects/nn9383k/ivar/arabidopsis/variation_raw_files/
cd $workdir

## Input parameters
sample=6020

## Do:
srun bcftools view -s $sample 1001genomes_snp-short-indel_with_tair10_only_ACGTN.vcf.gz -O z | bcftools view -q 0.000001 -O z > variants_${sample}.vcf.gz

