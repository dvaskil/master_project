#!/bin/bash

# Job name:
#SBATCH --job-name=prep_vcfsim
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit: 
#SBATCH --time=00-00:15:00
#
###arabidopsis 13min
###Dog 2 min
# 
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=500M
#SBATCH --ntasks=10  ## Equal to len(chromosome.txt)*2

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default
module load Python/3.6.6-fosscuda-2018b
module load OpenMPI/3.1.1-gcccuda-2018b 

export PATH=$PATH:$HOME/install/bin
source ~/install/graphenv/bin/activate

## Variable sample name:
sample_id=sample1

## Static variables:
maindir=/cluster/projects/nn9383k/eskil/vcf_simulation
sampledir=simulation_data/$sample_id
workdir=$maindir/$sampledir

individual_vcf="${sample_id}.vcf.gz"
linear_ref_fasta="$maindir/reference1-5.fa"

## Do
cd $workdir

while IFS= read -r chromosome; do
    srun --ntasks=1 graph_read_simulator prepare_simulation -c $chromosome --haplotype 0 --vcf $individual_vcf --reference $linear_ref_fasta &
    srun --ntasks=1 graph_read_simulator prepare_simulation -c $chromosome --haplotype 1 --vcf $individual_vcf --reference $linear_ref_fasta &
done < "../chromosomes.txt"
wait

