#!/bin/bash

# Job name:
#SBATCH --job-name=extract_vcf_sample
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
## Note: Lasted 6t15min
#SBATCH --time=00-05:00:00
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

## Prepare input files
workdir=/cluster/projects/nn9383k/cels2/graphs/dog
cd $workdir

## Input parameters
sample=Boxer01
vcf_file=all.vcf.gz

## Do:
srun bcftools view -s $sample $vcf_file -O z | bcftools view -q 0.000001 -O z > variant_${sample}.vcf.gz

