#!/usr/bin/env bash
outdir=seecerOut

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
fi

seecerPE.sh -d "$outdir" -k 20 -- read_r1.fastq.gz read_r2.fastq.gz
