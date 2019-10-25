#!/bin/bash

while true; do
    echo "Input parameter filename: "
    read infile

    start_range=$(awk 'FNR == 1 {print $2}' $infile)
    max_range=$(awk 'FNR == 2 {print $2}' $infile)
    error_step=$(awk 'FNR == 3 {print $2}' $infile)
    start_coverage=$(awk 'FNR == 4 {print $2}' $infile)
    max_coverage=$(awk 'FNR == 5 {print $2}' $infile)
    coverage_step=$(awk 'FNR == 6 {print $2}' $infile)

    now=$(date +"%H:%M:%S")

    dir_name="coverage${start_coverage}-${max_coverage}step${coverage_step}_error${start_range}-${max_range}step${error_step}"
    simdir=/data/graphs/human_21_and_22/output/$dir_name/simulated_output
    aligndir=/data/graphs/human_21_and_22/output/$dir_name/np_align
    
    printf "\nRun with these parameters\nError start:\t$start_range\nError max:\t$max_range\nError step:\t${error_step}\nStart coverage:\t$start_coverage \
       	    \nMax coverage:\t$max_coverage\nCoverage step:\t$coverage_step\n\nDo you want to continue? [y/n] Or do you want to use another file [f]\n"

    read ynf
    case $ynf in
	[Yy] )
	    printf "RUN START $now\n" > log_$infile
	    mkdir -p $simdir
	    mkdir -p $aligndir
	    for coverage in $(seq $start_coverage $coverage_step $max_coverage)
	    do
		for i in $(seq $start_range $error_step $max_range)
		do
		    printf "\nSIMULATING READS $now\nCoverage:\t$coverage/$max_coverage\nError rate:\t$i/$max_range\n\n"
		    cat haplotypes.txt | parallel --line-buffer -j 4 "graph_read_simulator simulate_reads -s $i {} $coverage" | \
			graph_read_simulator assign_ids $simdir/positions_c${coverage}_e${i}.tsv $simdir/simulated_reads_c${coverage}_e${i}.fa
		    a=($(wc -l $simdir/positions_c${coverage}_e${i}.tsv))
		    reads=${a[0]}
		    printf "\nMAPPING TO NUMPY$now\nNumber of Reads: $reads\n\n"
		    bwa mem ref.fa $simdir/simulated_reads_c${coverage}_e${i}.fa | numpy_alignments store sam $aligndir/bwa_c${coverage}_e${i} $reads
		    printf "\nSTORING TRUTH $now\n"
		    cat $simdir/positions_c${coverage}_e${i}.tsv | numpy_alignments store truth $aligndir/truth_c${coverage}_e${i} $reads
		    printf "\nNow done:\nCoverage:\t$coverage/$max_coverage\nError rate:\t$i/$max_range\n" >> log_$infile
		done
	    done
	    printf "\nDone!\n\n"
	    printf "\nFINISHED RUN $now\n" >> log_$infile
	    exit
	    ;;
	[Nn] )
	    echo "EXITING PROGRAM"
	    exit
	    ;;
	[Ff] )
	    continue 1 #starts over from the outmost loop (the while loop)
	    ;;
	* )
	    echo "Invalid input... try again"
	    ;;
    esac
done
