#!/usr/bin/env bash

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/AddOrReplaceReadGroups.jar INPUT=./hjIs21.1/hjIs21.uniq.sort.rmdup.bam OUTPUT=./hjIs21.1/hjIs21.1.uniq.sort.rmdup.group.bam SORT_ORDER=coordinate RGLB=1 RGPL=illumina RGPU=1 RGSM=hjIs21 VALIDATION_STRINGENCY=LENIENT

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/ReorderSam.jar INPUT=./hjIs21.1/hjIs21.1.uniq.sort.rmdup.group.bam OUTPUT=./hjIs21.1/hjIs21.1.uniq.sort.rmdup.group.reorder.bam REFERENCE=../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/AddOrReplaceReadGroups.jar INPUT=./hjIs21.2/hjIs21.uniq.sort.rmdup.bam OUTPUT=./hjIs21.2/hjIs21.2.uniq.sort.rmdup.group.bam SORT_ORDER=coordinate RGLB=1 RGPL=illumina RGPU=1 RGSM=hjIs21 VALIDATION_STRINGENCY=LENIENT

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/ReorderSam.jar INPUT=./hjIs21.2/hjIs21.2.uniq.sort.rmdup.group.bam OUTPUT=./hjIs21.2/hjIs21.2.uniq.sort.rmdup.group.reorder.bam REFERENCE=../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/AddOrReplaceReadGroups.jar INPUT=./hjIs21.3/hjIs21.uniq.sort.rmdup.bam OUTPUT=./hjIs21.3/hjIs21.3.uniq.sort.rmdup.group.bam SORT_ORDER=coordinate RGLB=1 RGPL=illumina RGPU=1 RGSM=hjIs21 VALIDATION_STRINGENCY=LENIENT

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/ReorderSam.jar INPUT=./hjIs21.3/hjIs21.3.uniq.sort.rmdup.group.bam OUTPUT=./hjIs21.3/hjIs21.3.uniq.sort.rmdup.group.reorder.bam REFERENCE=../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/AddOrReplaceReadGroups.jar INPUT=./hjIs21.4/hjIs21.uniq.sort.rmdup.bam OUTPUT=./hjIs21.4/hjIs21.4.uniq.sort.rmdup.group.bam SORT_ORDER=coordinate RGLB=1 RGPL=illumina RGPU=1 RGSM=hjIs21 VALIDATION_STRINGENCY=LENIENT

java -jar /n/site/inst/Linux-x86_64/bioinfo/picard/picard-tools-1.49/ReorderSam.jar INPUT=./hjIs21.4/hjIs21.4.uniq.sort.rmdup.group.bam OUTPUT=./hjIs21.4/hjIs21.4.uniq.sort.rmdup.group.reorder.bam REFERENCE=../ce_ws210/genome.fa VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true
