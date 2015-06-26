#!/usr/bin/env bash
set -x

detonatePE.sh -e -t 2 -- reads/reads_r1.fastq.gz reads/reads_r2.fastq.gz assembly/trinityOut.fasta 
