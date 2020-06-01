#!/bin/bash

# Job name:
#SBATCH --job-name=vcfy_sim
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-00:21:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --mem-per-cpu=2G
#SBATCH --ntasks=5

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

## Modules
module --quiet purge  # Reset the modules to the system default
module load Python/3.6.6-fosscuda-2018b
module load OpenMPI/3.1.1-gcccuda-2018b 

## Prepare input files
workdir=/cluster/projects/nn9383k/eskil/arabidopsis/vcf_sim/raw_and_intermediate_files
cd $workdir

## Do:
for region in {1..5}; do
    srun --ntasks=1 -i none vcfy -r $region -m 0.0431 -o sim_vcfy_chr$region.vcf TAIR10_numbered_chr.fa &
done
wait
