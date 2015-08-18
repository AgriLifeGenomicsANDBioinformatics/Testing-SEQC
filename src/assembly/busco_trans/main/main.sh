#!/usr/bin/env bash
set -x

../busco_trans.sh -t 4 -d out -- assembly/transcriptome1.fa
../busco_trans.sh -t 4 -d out -- assembly/transcriptome2.fasta
