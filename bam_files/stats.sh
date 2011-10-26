#!/usr/bin/env bash


java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/CollectAlignmentSummaryMetrics.jar I= ./hjIs21.1/hjIs21.uniq.sort.rmdup.bam O= ./hjIs21.1/hjIs21.1.uniq.sort.rmdup.alignment_sum REFERENCE_SEQUENCE= ../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT
java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/CollectAlignmentSummaryMetrics.jar I= ./hjIs21.2/hjIs21.uniq.sort.rmdup.bam O= ./hjIs21.2/hjIs21.2.uniq.sort.rmdup.alignment_sum REFERENCE_SEQUENCE= ../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT
java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/CollectAlignmentSummaryMetrics.jar I= ./hjIs21.3/hjIs21.uniq.sort.rmdup.bam O= ./hjIs21.3/hjIs21.3.uniq.sort.rmdup.alignment_sum REFERENCE_SEQUENCE= ../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT
java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/CollectAlignmentSummaryMetrics.jar I= ./hjIs21.4/hjIs21.uniq.sort.rmdup.bam O= ./hjIs21.4/hjIs21.4.uniq.sort.rmdup.alignment_sum REFERENCE_SEQUENCE= ../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT
