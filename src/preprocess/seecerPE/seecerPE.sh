#!/usr/bin/env bash
# ------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:k: -l help,outdir:,kmerSize: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"


# Defaults
kmerSize=25

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -k|--kmerSize)	
      kmerSize="$2"
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

# Read input files
read1="$1"
read2="$2"
outdir="$3"

# Less common prefix
lcprefix="$(printf "%s\n" "$(basename "$read1")" "$(basename "$read2")" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')"
prefix="${lcprefix%_[rR]}"

# Create tmp and output directories
readsDir="$(dirname "$read1")"
temp="${PWD}/${prefix}"
logfile="${PWD}/${prefix}_seecerPE.log"

mkdir -p "$temp"
mkdir -p "$outdir"

# Gunzip in parallel in case they are compressed
# Process substitution doesn't work with Seecer, i.e. <(zcat read)
if [[ "$read1" =~ \.gz$ ]] && [[ "$read2" =~ \.gz$ ]] ;
then
  gunzip "$read1" &
  gunzip "$read2" &
  wait %1 %2 || exit $?
  fqFile1="${read1%".gz"}"
  fqFile2="${read2%".gz"}"
else
  fqFile1="${read1}"
  fqFile2="${read2}"
fi

# Run
run_seecer.sh -t "$temp" -k "$kmerSize" "$fqFile1" "$fqFile2"  &>"$logfile"

# Re-compress fq files
for f in "${readsDir}/${prefix}"*; do
  if [ -f "$f" ];then
    gzip "$f" &
  fi
done
wait || exit $?

# Move files to outdir
for f in "${readsDir}/${prefix}"*fastq_*.gz; do
  if [ -f "$f" ];then
    mv "$f" "$outdir" &
  fi
done
wait || exit $?

## Remove temp dir
if [ -d "$temp" ]
then
  rm -rf "$temp"
fi
