#!/bin/bash

# Job name:
#SBATCH --job-name=simulate_reads
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-00:10:00
#
# Output location and filename:
#SBATCH --output=$HOME/project/slurm/%j_%x.out
#
# Other parameters:
# ntasks=lines_in_haplotypes NoXY(44) X(46)
#SBATCH --ntasks=2
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

## Prepare input files
cd $USERWORK/simulation_data

## Make sure output is copied back after job finishes
## Using wildcard - must use quotes!!
## saveffile is automatically in $SCRATCH
savefile 'positions_*.tsv' 'simulated_reads_*.fa'

## User defined parameters:
file="hap_test.txt"
#file="haplotypesNoXY.txt"
coverage=1
err_min=0.01
err_max=0.05
err_ste=0.05

## Code:
for err in $(seq $err_min  $err_ste $err_max); do
    printf "\nRUNNING SIM\n"
    while IFS= read -r line; do
#	hapn=$(echo $line | awk 'OFS="_" {print $1, $2}')
	srun --ntasks=1 -i none graph_read_simulator simulate_reads -s $err "$line" $coverage > $SCRATCH/simulations${err}_$(echo $line | awk 'OFS="_" {print $1, $2}').tmp &
    done < "$file"
    wait
    #Open all tmp files and assign ids. Storing positions and reads (.fa)
    printf "\nSTORING POS\n"
    cat $SCRATCH/simulations${err}*.tmp | graph_read_simulator assign_ids $SCRATCH/positions_c${coverage}_e${err}.tsv $SCRATCH/simulated_reads_c${coverage}_e${err}.fa
done

printf "\nSCRATCH"

ls -lh $SCRATCH
