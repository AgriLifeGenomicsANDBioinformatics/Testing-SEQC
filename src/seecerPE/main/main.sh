#!/usr/bin/env bash
set -x

seecerPE.sh -k 20 -- reads/read1_r1.fastq.gz reads/read1_r2.fastq.gz
seecerPE.sh -k 20 -- reads/read2_r1.fastq.gz reads/read2_r2.fastq.gz
