#!/usr/bin/env bash
set -x


if [ -d "$outdir" ]
then
  rm -rf "$outdir"
fi

detonatePE.sh -e -- reads_r1.fastq.gz reads_r2.fastq.gz trinityOut.fasta 
