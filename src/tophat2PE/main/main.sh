#!/usr/bin/env bash
outdir="tophat2PEOut"

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
  rm *.log
fi

set -x
../tophat2PE.sh -- reference/test_ref1.fa reads/reads_1* reads/reads_2* "$outdir"
../tophat2PE.sh -- reference/test_ref2.fa reads/reads_1* reads/reads_2* "$outdir"
