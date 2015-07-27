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

TEMP=$(getopt -o hd:t:s: -l help,outdir:,threads:,sequence_type -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
threads=1
sequence_type="RNA"

# Options
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
    -t|--threads)	
      threads="$2"
      shift 2
      ;;
    -s|--sequence_type)	
      sequence_type="$2"
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
sequences_file="$1"
sequences_name="$(basename "$sequences_file")"

# Output file and Logfile
prefix="${sequences_name%.*}"
outfile="${outdir}/${prefix}_ma.fa"
logfile="${PWD}/${prefix}.log"

# Create output directory
mkdir -p "$outdir"
touch "$logfile"

# Run
echo "$(date): Starting multiple alignment ..." | tee -a "$logfile"
clustalo --threads "$threads" \
    --seqtype "$sequence_type" \
    -i "$sequences_file" \
    -o "$outfile" \
    2>>"$logfile"

# Done
echo "$(date): Done." | tee -a "$logfile"
