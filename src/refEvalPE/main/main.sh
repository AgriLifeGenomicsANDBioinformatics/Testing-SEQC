#!/usr/bin/env bash
outdir="/Users/jordi/code/linux/bin/rnaSeq/src/refEvalPE/main/refEvalPEOut"

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
fi

set -x
refEvalPE.sh -- assemblies/toy_assembly_1.fa reference/toy_ref.fa reads/toy_SE.fq reads/toy_SE.fq "$outdir"
