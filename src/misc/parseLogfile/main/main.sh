#!/usr/bin/env bash
outfile="out/output.log"

if [ -f "${outfile}" ];
then
  rm "${outfile}"
fi

../parseLogfile.sh filteringPE
