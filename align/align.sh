#!/usr/bin/env bash

cd /scratch/jfv/mak_snp_analysis/ensembl/hjIs21.align/hjIs21.1
/n/projects/jfv/biobot/align/bwaAlignLane_dmel.sh 1 hjIs21 1 /scratch/jfv/mak_snp_analysis/hjIs21.sequences
cd /scratch/jfv/mak_snp_analysis/ensembl/hjIs21.align/hjIs21.2
/n/projects/jfv/biobot/align/bwaAlignLane_dmel.sh 2 hjIs21 2 /scratch/jfv/mak_snp_analysis/hjIs21.sequences
cd /scratch/jfv/mak_snp_analysis/ensembl/hjIs21.align/hjIs21.3
/n/projects/jfv/biobot/align/bwaAlignLane_dmel.sh 3 hjIs21 3 /scratch/jfv/mak_snp_analysis/hjIs21.sequences
cd /scratch/jfv/mak_snp_analysis/ensembl/hjIs21.align/hjIs21.4
/n/projects/jfv/biobot/align/bwaAlignLane_dmel.sh 4 hjIs21 4 /scratch/jfv/mak_snp_analysis/hjIs21.sequences


