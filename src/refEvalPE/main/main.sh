#!/usr/bin/env bash
outdir="refEvalPEOut"

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
  rm *.log
fi

refEvalPE.sh -- assemblies/refEvalPE_toy_assembly.fa reference/refEvalPE_toy_ref.fa reads/read_R1.* reads/read_R2.* "$outdir"
