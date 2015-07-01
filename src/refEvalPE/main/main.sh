#!/usr/bin/env bash
outdir="refEvalPEOut"

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
  rm *.log
fi

refEvalPE.sh -- assemblies/toy_assembly_1.fa reference/toy_ref.fa reads/read_R1.* reads/read_R2.* "$outdir"
