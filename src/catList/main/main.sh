#!/usr/bin/env bash
outfile=out/output.fa

if [ -f "${outfile}.gz" ];
then
  rm "${outfile}.gz"
fi

../catList.sh -c -o "$outfile" -- files/list.txt
