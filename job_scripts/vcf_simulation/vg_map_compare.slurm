#!/bin/bash

# Job name:
#SBATCH --job-name=vcfy_map
#
# Project:
#SBATCH --account=nn9383k
#
# Wall time limit:
#SBATCH --time=00-00:10:00
#
# Output location and filename:
#SBATCH --output=/cluster/home/eskilve/project/slurm/%j_%x.out
#
# Other parameters:
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
       
source $HOME/install/graphenv/bin/activate
export PATH=$PATH:$HOME/install/bin

## Modules
module --quiet purge  # Reset the modules to the system default
module load OpenMPI/3.1.1-gcccuda-2018b 
module load Python/3.6.6-fosscuda-2018b

## User defined variables: 
coverage=0.1
err=0.01
sample_id=sample1
readsdir=reads/$sample_id
workdir=/cluster/projects/nn9383k/eskil/vcf_simulation
mask="mixed_" # Either "masked_", "repeats_", "mixed_" or "" (empty string)
graphdir="graphs_0.0001"

## Prepare input/output: 
filename=_c${coverage}_e${err}
simread=$workdir/$readsdir/${mask}simulated_reads_${sample_id}$filename.fa
simposi=$workdir/$readsdir/${mask}positions_${sample_id}$filename.tsv
outdir=$SCRATCH
savefile '*mapq*.tsv' ## Savefile targets $SCRATCH; Using wildcard, must use quotes

## BEGIN
cd $workdir

printf "\nMapping and aligning with parameters:\nSample ID:\t$sample_id\nCoverage:\t$coverage\nError:\t$err\nMask:\t$mask\n"
srun $HOME/project/job_scripts/vg_mapping.sh $coverage $err $simread $simposi $outdir $graphdir

printf "\nGETTING CORRECT RATES\n"
# Fast for loop; will iterate over files in $SCRATCH and output mapping accuracy for different read-types and mapQ scores
if [ -z "$mask" ]; then mask="unmasked_"; fi # Check if string is empty and give outfile proper name
for var in all variants nonvariants; do
    for mapq in 0 40; do
	outfile=$outdir/${mask}${var}_${graphdir}_${sample_id}${filename}_mapq${mapq}.tsv
	printf "Matching mapping accuracy with vg map. Coverage: $coverage\nErrRate\tMatch\n" > $outfile
	outfilename=${graphdir}_c${coverage}_e${err}
	numpy_alignments get_correct_rates $outdir/truth$outfilename $outdir/vggraph$outfilename $var -m $mapq >> $outfile
    done
done
wait

printf "\nSCRATCH\n"
ls -lh $SCRATCH

printf "\nDONE\n"

