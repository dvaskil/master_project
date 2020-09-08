#!/bin/bash


# Job name:
#SBATCH --job-name=ar_extract_sample
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
## Note: Lasted 6t15min (without the numbering part)
#SBATCH --time=00-06:20:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=256M


# Description:
# Job script for extracting a vcf from one sample in a multi-sample vcf


## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default
module load BCFtools/1.9-foss-2018b

## Input parameters
sample=801

## Static
vcf_file=/cluster/projects/nn9383k/eskil/arabidopsis/data_files/vcfs/1001genomes_snp-short-indel_with_tair10_only_ACGTN.vcf.gz
workdir=/cluster/projects/nn9383k/eskil/arabidopsis2/simulation_data
mkdir -p $workdir/$sample
cd $workdir/$sample

## BEGIN
printf "\nCreating sample vcf\t$(date +%F%t%T)\n"
srun bcftools view -s $sample $vcf_file -O z | bcftools view -q 0.000001 -O v > variant_${sample}.vcf

# Comress and index
printf "\nbgzip vcf\t$(date +%F%t%T)\n"
bgzip variant_${sample}.vcf

printf "\ntabix vcf\t$(date +%F%t%T)\n"
tabix -p vcf variant_${sample}.vcf.gz

