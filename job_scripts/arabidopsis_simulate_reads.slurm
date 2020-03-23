#!/bin/bash

# Job name:
#SBATCH --job-name=simulate_reads_ara
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
# N: c0.2=7min
#SBATCH --time=00-00:08:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
# ntasks=lines_in_haplotypes (10)
#SBATCH --ntasks=10
#SBATCH --mem-per-cpu=4G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
       
module --quiet purge  # Reset the modules to the system default
module load OpenMPI/3.1.1-gcccuda-2018b 
module load Python/3.6.6-fosscuda-2018b
#module list

source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Make sure output is copied back after job finishes
## Using wildcard - must use quotes!!
## saveffile is automatically in $SCRATCH
savefile 'positions_*.tsv' 'simulated_reads_*.fa'

## Prepare input files
workdir=$USERWORK/arabidopsis/simulation_data/1622_novg
cd $workdir

## User defined parameters:
file="haplotypes.txt"
coverage=0.1
err=0.01
id=1622

## Code:
printf "\nRUNNING SIM\n"
while IFS= read -r line; do
    srun --ntasks=1 -i none graph_read_simulator simulate_reads -s $err "$line" $coverage > $SCRATCH/simulations${err}_$(echo $line | awk 'OFS="_" {print $1, $2}').tmp &
done < "$file"
wait

#Open all tmp files and assign ids. Storing positions and reads (.fa)
printf "\nSTORING POS\n"
cat $SCRATCH/simulations${err}*.tmp | graph_read_simulator assign_ids $SCRATCH/positions_${id}_c${coverage}_e${err}.tsv $SCRATCH/simulated_reads_${id}_c${coverage}_e${err}.fa
printf "\nDONE\n"

printf "\nSCRATCH"
ls -lh $SCRATCH

