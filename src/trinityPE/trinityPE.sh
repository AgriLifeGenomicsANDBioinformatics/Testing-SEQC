#!/usr/bin/env bash
# ------------------------------------------------------------------
set -f #Disable pathname expansion.  
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:m:t: -l help,outdir:,maxMem:,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

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
read1="$1"
read2="$2"
readsDir="$(dirname "$read1")"
outLevel="$(dirname "$readsDir")"
outdir="${outLevel}/trinityPEOut"
logfile="${outdir}/${prefix}.log"

# Less common prefix
lcprefix="$(printf "%s\n" "$read1" "$read2" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')"
prefix="${lcprefix%_[rR]}"

# Create output directory
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
Trinity --normalize_reads --output "$outdir" --seqType fq --max_memory "$maxMem" \
  --left "$fqFile1" --right "$fqFile2" --CPU "$threads" &>"$logfile"

# Re-compress fq files
gzip "$fqFile1" &
gzip "$fqFile2" &
wait %1 %2 || exit $?

#Copy logfile in the working directory
cp "$logfile" ./
