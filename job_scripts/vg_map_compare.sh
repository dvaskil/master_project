#!/bin/bash
: '
This pipeline use vg map to map simulated reads, then piping it to numy alignments for comparison.
Input is as follows:
1. coverage of the genome the reads are simulated from
2. substitusion error rate of the simulated reads
3. FASTA file of the simulated reads (.fa)
4. File containing the positions of the simulated reads (.pos)
5. Output directory where the result of the mapping accuracy is stored
6. Name of dir containing vg graphs for naming the outfile
7. to include/exclude variants: "all", "variants" or "nonvariants"
8. MapQ score threshold/cutoff
9. ID number of sample
10. masked or not
'
coverage=$1
err=$2
simread=$3
simposi=$4
outdir=$5
graphdir=$6
var=$7
mapq=$8
sample_id=$9
mask=${10}

if [ -z "$mask" ]; then mask="both_"; fi
printf "\nmask: $mask\n"

filename=_c${coverage}_e${err}
outfile=$outdir/${mask}${var}_${sample_id}_${graphdir}${filename}_mapq${mapq}.tsv

printf "\nsimread $simread\nsimposi $simposi\n outdir $outdir"
printf "Matching mapping accuracy with vg map. Coverage: $coverage\nErrRate\tMatch\n" > $outfile

printf '\nMAPPING\n\n'
vg map -t 8 -d graph -f $simread --refpos-table > $outdir/vg$filename.pos
		    
#Find number of reads for array dimensions
a=($(wc -l $outdir/vg$filename.pos))
reads=${a[0]}

printf '\nNUMPY ALIGN\n\n'
cat $outdir/vg$filename.pos | numpy_alignments store pos $outdir/vggraph$filename $reads

printf '\nNUMPY ALIGN TRUTH\n\n'
cat $simposi | numpy_alignments store truth $outdir/truth$filename $reads

printf "\nGETTING CORRECT RATES\n"
numpy_alignments get_correct_rates $outdir/truth$filename $outdir/vggraph$filename $7 -m $mapq >> $outfile # | awk 'FNR == 1 {print '$err' "\t" $2}' >> $outfile

cat $outfile
cp $outfile $HOME/project
printf '\nFINISHED\n\n'
