#!/usr/bin/env bash
outfile=out/output.fa

if [ -f "${outfile}.gz" ];
then
  rm "${outfile}.gz"
fi

../catList.sh -o "$outfile" -- files/list.txt
