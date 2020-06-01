#!/bin/bash

# Job name:
#SBATCH --job-name=vcfsim_graph
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
# sim_vcf10x=50min
#SBATCH --time=00-02:00:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=1 --cpus-per-task=3
#SBATCH --mem-per-cpu=6G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
       
source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Modules
module --quiet purge  # Reset the modules to the system default
module load BCFtools/1.9-intel-2018b

# Parameters: 
#        0      1      2      3     4     5    6     7   8   9   10
list="0.0001 0.00025 0.0005 0.001 0.005 0.01 0.025 0.05 0.1 0.2 0.5"
arr=($list)
threshold=${arr[10]}

chromosomes="1,2,3,4,5"

# Setting up work environment: 
workdir=/cluster/projects/nn9383k/eskil/vcf_simulation
cd $workdir

# Make a directory for this graph, go to that directory
mkdir -p graphs_$threshold 
cd graphs_$threshold 

printf "\nCreating graph for $threshold threshold!\n\n"

## VCF ##
echo "Creating vcf"
bcftools view -q $threshold $workdir/sim_vcfy_chr1-5.vcf.gz -O z > filtered.vcf.gz
tabix -p vcf filtered.vcf.gz
echo "Done creating vcf"

## Construct ##
for chromosome in $(echo $chromosomes | tr "," "\n"); do
    vg construct -C -m 32 -r $workdir/reference1-5.fa -v filtered.vcf.gz -R $chromosome > graph$chromosome.vg & 
done
wait
echo "Done constructing"

## IDs ##
vg ids -j graph1.vg graph2.vg graph3.vg graph4.vg graph5.vg 
echo "Done vg ids"

## XG index ##
mkdir $SCRATCH/xg_tmp
export TMPDIR=$SCRATCH/xg_tmp
vg index --progress -x graph.xg graph1.vg graph2.vg graph3.vg graph4.vg graph5.vg 
echo "Done xg index"

## Prune ##
for chromosome in $(echo $chromosomes | tr "," "\n"); do
    date 
    echo "Pruning chromosome $chromosome" 
    vg prune -p -r graph$chromosome.vg > graph$chromosome.pruned.vg & 
done 
wait 
echo "Done pruning"

## GCSA index ##
mkdir $SCRATCH/gcsa_tmp
export TMPDIR=$SCRATCH/gcsa_tmp
vg index -p -g graph.gcsa *.pruned.vg > log_gcsa.txt
echo "Done gcsa"

## Log ##
printf "\nDone creating graph for $threshold threshold!\n\n"
touch $workdir/constructed.log
printf "$threshold\t$(date +%F%t%T)\n" >> $workdir/constructed.log

