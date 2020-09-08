#!/bin/bash

# Job name:
#SBATCH --job-name=dog_map
#
# Project:
#SBATCH --account=nn9383k
#
# Partition:
#SBATCH --partition=bigmem
#
# Wall time limit:
#SBATCH --time=00-02:00:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=11 --cpus-per-task=8
#SBATCH --mem=64G
#
# C0.1 11-30min
# Wolf05 > 30 min
#
## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
       
source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Modules
module --quiet purge  # Reset the modules to the system default
module load OpenMPI/3.1.1-gcccuda-2018b 
module load Python/3.6.6-fosscuda-2018b

## User defined parameters:
coverage=0.1
err=0.01
mask="" # Either "masked_", "repeat_", "mixed_" or "" (empty string)
sample_id=boxer01

## Static parameters
readsdir=reads/$sample_id
workdir=/cluster/projects/nn9383k/eskil/dog
outdir=$SCRATCH
filename=_${sample_id}_c${coverage}_e${err}

# Will take variables defined abpve to set correct positions and reads files
simread=$workdir/$readsdir/${mask}simulated_reads$filename.fa
simposi=$workdir/$readsdir/${mask}positions$filename.tsv

## Make sure output is copied back after job finishes
## Using wildcard - must use quotes!!
## savefile is automatically in $SCRATCH
savefile 'rates_*.tsv' # '*graphs_*.tsv' #'truth*.npz' 'vggraph*.npz' 'vg_*.pos'

## BEGIN
cd $workdir

# Slow for loop; uses vg map and will create all neccecary files
for graphdir in graphs_0.0001 graphs_0.00025 graphs_0.0005 graphs_0.001 graphs_0.005 graphs_0.01 graphs_0.025 graphs_0.05 graphs_0.1 graphs_0.2 graphs_0.5; do
    srun --ntasks=1 -i none $HOME/project/job_scripts/vg_mapping.sh $coverage $err $simread $simposi $outdir $graphdir &
done
wait

printf "\nGETTING CORRECT RATES\n"
# Fast for loop; will iterate over files in $SCRATCH and output mapping accuracy for different read-types and mapQ scores
if [ -z "$mask" ]; then mask="unmasked_"; fi # Check if string is empty and give outfile proper name
for graphdir in graphs_0.0001 graphs_0.00025 graphs_0.0005 graphs_0.001 graphs_0.005 graphs_0.01 graphs_0.025 graphs_0.05 graphs_0.1 graphs_0.2 graphs_0.5; do
    for var in all variants nonvariants; do
	for mapq in 0 40; do
	    outfile=$outdir/${mask}${var}_${graphdir}${filename}_mapq${mapq}.tsv
	    printf "Matching mapping accuracy with vg map. Coverage: $coverage\nErrRate\tMatch\n" > $outfile
	    outfilename=${graphdir}_c${coverage}_e${err}
	    numpy_alignments get_correct_rates $outdir/truth$outfilename $outdir/vggraph$outfilename $var -m $mapq >> $outfile
	done
    done
done

cd $outdir
for mq in 0 40; do 
    awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_all_*mapq${mq}.tsv > rates_${mask}all_${sample_id}_c${coverage}_e${err}_mapq${mq}.tsv
    awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_variants_*mapq${mq}.tsv > rates_${mask}variants_${sample_id}_c${coverage}_e${err}_mapq${mq}.tsv
    awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_nonvariants_*mapq${mq}.tsv > rates_${mask}nonvariants_${sample_id}_c${coverage}_e${err}_mapq${mq}.tsv
done
sed -i '1s/^/cutoff\trecall_rate\tfalse_positive\n/' rates_* # Adding headers to output files

