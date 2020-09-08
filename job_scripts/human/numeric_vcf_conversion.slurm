#!/bin/bash

# Description: 
# Files downloaded from GIAB have #CHROM column as 'chrN'. This script converts the denomination to numerical.
#
# Job name:
#SBATCH --job-name=num_vcf
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-01:10:00
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
module load BCFtools/1.9-intel-2018b

## Parameters
zip_file=hg001_hg38_GIAB_chr1-X.vcf.gz
vcf_file=${zip_file%.gz}
num_name=${vcf_file%.vcf}_numeric.vcf

## Prepare input files
workdir=/cluster/projects/nn9383k/eskil/hg38/simulation_data/hg001
cd $workdir

## BEGIN
printf "\nUnzipping\n"
bgzip -d $zip_file

printf "\nRemoving chromosome X\n"
sed -i '/^chrX/,$d' $vcf_file

printf "\nConverting to numerical\n"
srun awk '{gsub(/^chr/,""); print}' $vcf_file > $num_name
rm $vcf_file

printf "\nZipping\n"
bgzip $num_name

