#!/usr/bin/env bash
set -x

../busco_trans.sh -t 4 -- assembly/transcriptome1.fa out
../busco_trans.sh -t 4 -- assembly/transcriptome2.fasta out
