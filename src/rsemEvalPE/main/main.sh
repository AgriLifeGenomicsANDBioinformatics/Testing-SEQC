#!/usr/bin/env bash
set -x

rsemEvalPE.sh -t 2 -- reads/reads1_r1.fastq.gz reads/reads1_r2.fastq.gz assembly/trinityOut1.fasta 
rsemEvalPE.sh -t 2 -- reads/reads2_r1.fastq.gz reads/reads2_r2.fastq.gz assembly/trinityOut2.fasta 
