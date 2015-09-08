#!/usr/bin/env bash
# ------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find perl scripts
perl_script="${script_absdir}/perl/${script_name}.pl"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t: -l help,outdir:,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
threads=1

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
homologous_input="$1"
homologous_directory="$(readlink -f "$homologous_input")"

# Get the files to process
files="$(ls ${homologous_directory})"

# Output file and Logfile
outfile="${outdir}/${prefix}.txt"
logfile="${PWD}/${prefix}.log"

# Create output directory
mkdir -p "$outdir"
touch "$logfile"

# Run in parallel
echo "$(date): Starting with ${threads} threads..." | tee -a "$logfile"
export homologous_directory
export perl_script
echo "${files}" \
    | xargs -I {} --max-proc "$threads" bash -c ''$perl_script' "${homologous_directory}/"{}'

# Done
echo "$(date): Done." | tee -a "$logfile"
