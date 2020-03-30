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
'
coverage=$1
err=$2
simread=$3
simposi=$4
outdir=$5
graphdir=$6

cd $graphdir

outfilename=${graphdir}_c${coverage}_e${err}

printf "\nsimread $simread\nsimposi $simposi\n outdir $outdir"

printf '\nMAPPING\n\n'
vg map -t 8 -d graph -f $simread --refpos-table > $outdir/vg$outfilename.pos
		    
#Find number of reads for array dimensions
a=($(wc -l $outdir/vg$outfilename.pos))
reads=${a[0]}

printf '\nNUMPY ALIGN\n\n'
cat $outdir/vg$outfilename.pos | numpy_alignments store pos $outdir/vggraph$outfilename $reads

printf '\nNUMPY ALIGN TRUTH\n\n'
cat $simposi | numpy_alignments store truth $outdir/truth$outfilename $reads

printf '\nFINISHED CREATING FILES\n\n'

