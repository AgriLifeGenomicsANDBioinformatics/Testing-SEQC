#!/usr/bin/env bash
# ------------------------------------------------------------------
set -f #Disable pathname expansion.  
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Cat the help file if no arguments
if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

# Get options
TEMP=$(getopt -o hb:s:el:p:d: -l help,bootstrap:,seed:,singleEnd,length:,trimPrefix:,outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
bootstrap=100
seed=42
length=180
trimPrefix="_"
outdir=.

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -b|--bootstrap)	
      bootstrap="$2"
      shift 2
      ;;
    -s|--seed)	
      seed="$2"
      shift 2
      ;;
    -e|--singleEnd)		
      singleEnd=x
      shift
      ;;
    -l|--length)		
      length="$2"
      shift 2
      ;;
    -p|--trimPrefix)	
      trimPrefix="$2"
      shift 2
      ;;
    -d|--outdir)	
      outdir="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "$script_name.sh:Internal error!"
      exit 1
      ;;
  esac
done

indexFile=$1
fastqgzFile1=$2

if [ "$singleEnd" ]
then

  prefix="$(basename.sh "$fastqgzFile1" -x "$trimPrefix"'\.(fq.gz|fastq.gz)')"
  logFile="$outdir/$prefix.log"

  mkdir -p "$outdir"
  kallisto quant -i "$indexFile" -o "$outdir" -b "$bootstrap" --seed "$seed" --single -l "$length" <(zcat "$fastqgzFile1") 2>"$logFile" 

else

  fastqgzFile2=$3
  lcp="$(lcprefix.sh "$fastqgzFile1" "$fastqgzFile2")"
  prefix="$(basename.sh "$lcp" -x "$trimPrefix")"
  logFile="$outdir/$prefix.log"

  mkdir -p "$outdir"
  kallisto quant -i "$indexFile" -o "$outdir" -b "$bootstrap" --seed "$seed" <(zcat "$fastqgzFile1")  <(zcat "$fastqgzFile2") 2>"$logFile" 

fi

# Modify output file name
mv "$outdir/abundance.txt" "$outdir/"$prefix".txt"
mv "$outdir/abundance.h5" "$outdir/"$prefix".h5"
