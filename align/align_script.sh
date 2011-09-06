#!/bin/bash

CUR_DIR=$1
THREADS=$2

cd $CUR_DIR

for f in ./*.fastq.gz
do
  echo $f
  bowtie --solexa1.3-quals -S -p $THREADS ../d_melanogaster_fb5_22.ebwt/d_melanogaster_fb5_22 <(gunzip -c $f) > $f.sam
done
