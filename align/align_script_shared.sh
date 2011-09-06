#!/bin/bash

CUR_DIR=$1
THREADS=$2

Bowfiles[0]='/n/projects/jjj/genomics_course/sequence_data/ctbp_ip.fastq.gz'
Bowfiles[1]='/n/projects/jjj/genomics_course/sequence_data/ctbp_wce.fastq.gz'

cd $CUR_DIR

for f in ${Bowfiles[*]}
do
  echo $f
  bowtie --solexa1.3-quals -S -p $THREADS ../d_melanogaster_fb5_22.ebwt/d_melanogaster_fb5_22 <(gunzip -c $f) > file.sam
done
