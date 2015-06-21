#!/usr/bin/env bash
# ------------------------------------------------------------------
set -f #Disable pathname expansion.  
shopt -s extglob

script_name="$(basename "$0" .sh)"

TEMP=$(getopt -o hd:m:t: -l help,outdir:,maxMem:,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
outdir="out"

# Defaults
maxMem="1G"
threads=1

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -d|--outdir)	
      outdir="$2"
      shift 2
      ;;
    -m|--maxMem)	
      maxMem="$2"
      shift 2
      ;;
    -t|--threads)	
      threads="$2"
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

# Input reads
read1=$1
read2=$2
trinityOut="trinity_${outdir}"

# Less common prefix
lcprefix="$(printf "%s\n" "$read1" "$read2" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')"
prefix=${lcprefix%_[rR]}

# Create output directory
mkdir -p "$trinityOut"

# Gunzip in parallel
gunzip "$read1" &
gunzip "$read2" &
wait %1 %2 || exit $?
fqFile1="$(basename $read1 .gz)"
fqFile2="$(basename $read2 .gz)"

# Run
Trinity --normalize_reads --output "$trinityOut" --seqType fq --max_memory "$maxMem" --left "$fqFile1" --right "$fqFile2" --CPU "$threads" 2>"$trinityOut/$prefix.log"

# Re-compress fq files
gzip "$fqFile1" &
gzip "$fqFile2" &
wait %1 %2 || exit $?
