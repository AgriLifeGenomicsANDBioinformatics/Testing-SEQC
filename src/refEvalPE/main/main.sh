#!/usr/bin/env bash
outdir=refEvalPEOut

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
fi

set -x
refEvalPE.sh -- assemblies/toy_assembly_1.fa reference/toy_ref.fa reads/toy_SE.fq reads/toy_SE.fq refEvalPEOut
