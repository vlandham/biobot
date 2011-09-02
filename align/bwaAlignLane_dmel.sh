#!/usr/bin/env bash

#reference fasta
#assumes that you have created the bwa index
#to create index (larger genome): bwa index -a bwtsw <ref.fa>
#to create index (smaller genome): bwa index -a is <ref.fa>
refFa="/scratch/jfv/mak_snp_analysis/ensembl/ce_ws210/genome.fa"
refFai="/scratch/jfv/mak_snp_analysis/ensembl/ce_ws210/genome.fa.fai"

##max gap open and gap extensions, default 1, -1
GapOpen=1
GapExt=-1

##human readable sample name, used in output files
SmpName=$2
rgName=("@RG\tID:"$3"\tSM:ds\tPL:Illumina")
echo $SmpName

##Lane nme, based on lane number
LaneName1=("Lane"$1"Pt1")
LaneName2=("Lane"$1"Pt2")

##directory with fastq files
filepath=$4

##assumes fastq input files names s_1_2_sequence.txt, etc..
fn1=($filepath"/s_"$1"_1_sequence.txt.gz")
fn2=($filepath"/s_"$1"_2_sequence.txt.gz")

##bwa output file from bwa aln
saiOut1=($LaneName1".sai")
saiOut2=($LaneName2".sai")

##output filenames
#sam filename
samOut=($SmpName".sam.gz")

#bam filename, uniquely mapping
bamUnOut=($SmpName".uniq.bam")
#bam filename, uniquely mapping, sorted
bamUnOutS=($SmpName".uniq")
sortPrefix=($SmpName".uniq.sort")
bamSortOut=($sortPrefix".bam")
bamRmdupUnOutS=($SmpName".uniq.sort.rmdup.bam")
StatOut=($SmpName".idxstats")

echo "Start Time $(date)"
echo $LaneName1
echo "Starting bwa aln first end"

#aligns first lane
bwa aln -o $GapOpen -e $GapExt $refFa  $fn1 > $saiOut1

echo "Time - aln pt1 complete $(date)"
echo $LaneName2
echo "Starting bwa aln second end"

#aligns second lane
bwa aln -o $GapOpen -e $GapExt $refFa  $fn2 > $saiOut2

echo "Time - aln pt2 complete $(date)"
echo "Starting bwa sampe"

#align paired end reads
bwa sampe  -r $rgName $refFa  $saiOut1 $saiOut2 $fn1 $fn2 | gzip > $samOut

echo "Time - sampe complete $(date)"
#echo "Starting samtools conversions"

#creates bam file
samtools view -uS -bq 1  $samOut > $bamUnOut

samtools sort  $bamUnOut $sortPrefix
samtools rmdup $bamSortOut  $bamRmdupUnOutS
samtools index $bamRmdupUnOutS


echo "End Time $(date)"

