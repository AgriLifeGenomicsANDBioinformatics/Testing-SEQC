#!/usr/bin/env bash

outdir="cegmaOut"

if [ -d "$outdir" ]
then
  rm -rf "$outdir"
fi

set -x 

../cegma.sh -t 3 -- assembly/assembly1.fa coreGenes/coreGenes.fa "$outdir"
../cegma.sh -t 3 -- assembly/assembly2.fa.gz coreGenes/coreGenes.fa "$outdir"
