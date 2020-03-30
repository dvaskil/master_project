#!/bin/bash

# repeat_all_graphs_0.5_c0.1_e0.01_mapq40.tsv

mask=$(echo *all_*0.5*.tsv | awk -F "_" '{print $1}')
mq=$(echo *all_*0.5*.tsv | awk -F "_" '{print $7}')
mq=$(echo $mq | awk -F "." '{print $1}')

printf "$mask\n"
printf "$mq\n"

awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_all_*.tsv > ../${mask}_all_c0.1_e0.01_${mq}.tsv
awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_variants_*.tsv > ../${mask}_variants_c0.1_e0.01_${mq}.tsv
awk '{OFS="\t"} FNR==3 {split (FILENAME,f,"[_]"); print f[4], $2, $3}' *_nonvariants_*.tsv > ../${mask}_nonvariants_c0.1_e0.01_${mq}.tsv
