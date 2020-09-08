#!/bin/bash

# Job name:
#SBATCH --job-name=simulate_reads_dog
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-00:10:00
# c0.1 no more than 3 min (wolf05 3.11)
# c0.1 ~ 37 min, dot know why
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=76
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
savefile '*positions_*.tsv' '*simulated_reads_*.fa'

## User defined parameters:
sample=wolf05
coverage=0.1
err=0.01 # Simulated substitution error rate

## Prepare input files
workdir=/cluster/projects/nn9383k/eskil/dog/simulation_data
file=$workdir/haplotypes.txt
cd $workdir/$sample

## BEGIN:
printf "\nRUNNING SIM\n"
while IFS= read -r line; do
    #hapn=$(echo $line | awk 'OFS="_" {print $1, $2}')
    srun --ntasks=1 -i none graph_read_simulator simulate_reads -s $err "$line" $coverage > $SCRATCH/simulations${err}_$(echo $line | awk 'OFS="_" {print $1, $2}').tmp &
done < "$file"
wait

#Open all tmp files and assign ids. Storing positions and reads (.fa)
printf "\nSTORING POS\n"
cat $SCRATCH/simulations${err}*.tmp | graph_read_simulator assign_ids $SCRATCH/positions_${sample}_c${coverage}_e${err}.tsv $SCRATCH/simulated_reads_${sample}_c${coverage}_e${err}.fa
printf "\nDONE\n"

