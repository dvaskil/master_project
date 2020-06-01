#!/bin/bash

# Job name:
#SBATCH --job-name=dog_graph_construct
#
# Project:
#SBATCH --account=nn9383k
#
# Partition:
#SBATCH --partition=bigmem
#
# Wall time limit:
#SBATCH --time=00-06:00:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=1 --cpus-per-task=7
#SBATCH --mem-per-cpu=40G

## < 01:40:00
## 40G ON 0-6  ~~~  15G 7-10

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error

source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Modules
module --quiet purge  # Reset the modules to the system default
module load BCFtools/1.9-intel-2018b

# Parameters: 
#        0      1       2     3     4     5    6     7   8   9  10
list="0.0001 0.00025 0.0005 0.001 0.005 0.01 0.025 0.05 0.1 0.2 0.5"
arr=($list)
threshold=${arr[6]}

chromosomes="1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38"

# Setting up work environment: 
#Make a directory for this graph, go to that directory
workdir=/cluster/work/users/eskilve/dog
cd $workdir
mkdir $SCRATCH/xg_tmp
mkdir -p graphs_$threshold 
cd graphs_$threshold 

printf "\nCreating graph for $threshold threshold\n\n"

## VCF
echo "Creating vcf"
bcftools view -q $threshold $workdir/all_without_genotype_info_numeric.vcf.gz -O z > filtered.vcf.gz
tabix -p vcf filtered.vcf.gz
echo "Done creating vcf"

## Construct graph
for chromosome in $(echo $chromosomes | tr "," "\n"); do
    vg construct -C -m 32 -r $workdir/canFam3.1_numeric_trX.fa -v filtered.vcf.gz -R $chromosome > graph$chromosome.vg & 
done
wait
echo "Done constructing"

## IDs
vg ids -j graph1.vg graph2.vg graph3.vg graph4.vg graph5.vg graph6.vg graph7.vg graph8.vg graph9.vg graph10.vg graph11.vg graph12.vg \
graph13.vg graph14.vg graph15.vg graph16.vg graph17.vg graph18.vg graph19.vg graph20.vg graph21.vg graph22.vg graph23.vg graph24.vg graph25.vg \
graph26.vg graph27.vg graph28.vg graph29.vg graph30.vg graph31.vg graph32.vg graph33.vg graph34.vg graph35.vg graph36.vg graph37.vg graph38.vg
echo "Done vg ids"

## XG index
export TMPDIR=$SCRATCH/xg_tmp
vg index --progress -x graph.xg graph1.vg graph2.vg graph3.vg graph4.vg graph5.vg graph6.vg graph7.vg graph8.vg graph9.vg graph10.vg graph11.vg graph12.vg \
graph13.vg graph14.vg graph15.vg graph16.vg graph17.vg graph18.vg graph19.vg graph20.vg graph21.vg graph22.vg graph23.vg graph24.vg graph25.vg \
graph26.vg graph27.vg graph28.vg graph29.vg graph30.vg graph31.vg graph32.vg graph33.vg graph34.vg graph35.vg graph36.vg graph37.vg graph38.vg
echo "Done xg index"

## Pruning
for chromosome in $(echo $chromosomes | tr "," "\n"); do
    date 
    echo "Pruning chromosome $chromosome" 
    vg prune -p -r graph$chromosome.vg > graph$chromosome.pruned.vg & 
done 
wait 
echo "Done pruning"

## Logging
touch $workdir/construct.log
printf "$threshold\t$(date +%F%t%T)\n" >> $workdir/construct.log
printf "\nDone creating graph for $threshold threshold!\n\n"

