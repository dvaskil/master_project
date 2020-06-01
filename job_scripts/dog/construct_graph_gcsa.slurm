#!/bin/bash

# Job name:
#SBATCH --job-name=dog_gcsa
#
# Project:
#SBATCH --account=nn9383k
#
# Partition:
#SBATCH --partition=bigmem
#
# Wall time limit:
#SBATCH --time=01-12:00:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=1 --cpus-per-task=11
#SBATCH --mem-per-cpu=8G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Modules
module --quiet purge  # Reset the modules to the system default

# Parameters: 
#        0      1       2     3     4     5    6     7   8   9  10
list="0.0001 0.00025 0.0005 0.001 0.005 0.01 0.025 0.05 0.1 0.2 0.5"
arr=($list)
threshold=${arr[1]}

# Setting up work environment: 
workdir=/cluster/work/users/eskilve/dog
cd $workdir
cd graphs_$threshold

mkdir $SCRATCH/gcsa_tmp
export TMPDIR=$SCRATCH/gcsa_tmp

printf "\nCreating gcsa index for $threshold\n"

vg index -Z 4096 -t 11 -p -g graph.gcsa *.pruned.vg > log_gcsa.txt

echo "Done gcsa"

printf "$threshold\t$(date +%F%t%T)\n" >> $workdir/gcsa_index.log
printf "\nDone creating GCSA index for $threshold threshold!\n\n"
