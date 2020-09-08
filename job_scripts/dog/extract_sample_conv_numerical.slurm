#!/bin/bash
#
# Job name:
#SBATCH --job-name=dog_extract_sample
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-04:00:00
### 6t15min -without the numbering part)
### 2t41min -with sed and awk
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
sample_id=IndigenousDogNigeria04

## Static
vcf_file=/cluster/projects/nn9383k/eskil/dog/data_files/raw_files/all.vcf.gz
workdir=/cluster/projects/nn9383k/eskil/dog/simulation_data

sample=$(echo $sample_id | tr '[:upper:]' '[:lower:]') # I like lowercase on my files and dirs
mkdir -p $workdir/$sample
cd $workdir/$sample

## BEGIN
printf "\nExtracting sample $sample_id\nAlso removing X and making numerical chromosomes ('chr1' to '1')"
srun bcftools view -s $sample_id $vcf_file -O z | bcftools view -q 0.000001 -O v > variant_${sample}.vcf

# Truncate X chromosome lines
sed -i '/^chrX/,$d' variant_${sample}.vcf

# Change 'chrN' to 'N'
awk '{gsub(/^chr/,""); print}' variant_${sample}.vcf > variant_${sample}_numeric_trX.vcf

# Comress and index
bgzip variant_${sample}_numeric_trX.vcf
tabix -p vcf variant_${sample}_numeric_trX.vcf.gz

