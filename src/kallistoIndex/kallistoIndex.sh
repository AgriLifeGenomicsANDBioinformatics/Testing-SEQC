#!/usr/bin/env bash
# ------------------------------------------------------------------
set -f #Disable pathname expansion.  
shopt -s extglob

script_name=$(basename "$0" .sh)	

TEMP=$(getopt -o hk:d:fx -l help,kmer:,outdir:,outfilename,outsuffix -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

abspath_script=$(readlink -f -e "$0")	
script_absdir=$(dirname "$abspath_script")
kmer=31
outdir=.

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -k|--kmer)	
      kmer="$2"
      shift 2
      ;;
    -d|--outdir)	
      outdir="$2"
      shift 2
      ;;
    -f|--outfilename)		
      outfilename=x
      shift
      ;;
    -x|--outsuffix)
      outsuffix=x
      shift
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

refGenome=$1
basename="$(basename.sh "$refGenome" -x '\.(fa|fasta)' )"

# Output file name
if [ $outsuffix ]
then
  outfile="$outdir/"$basename"_"$kmer".idx"
else
  outfile="$outdir/"$basename".idx"
fi

# Create output directory
mkdir -p "$outdir"

# Run
if [ $outfilename ]
then
    echo "$outfile"
else
    kallisto index -k "$kmer" -i "$outfile"  "$refGenome"
fi

