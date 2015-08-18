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

TEMP=$(getopt -o ht:d: -l help,threads:.outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
threads=1
outdir="$PWD"

# Options
while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -t|--threads)	
      threads="$2"
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

# Read input files
transcriptome="$1"

# Setting some file/dirnames
transcriptome_basename="$(basename "$transcriptome")"
transcriptome_path="$(realpath "$transcriptome")"
prefix="${transcriptome_basename%%.*}"
logfile="${PWD}/${prefix}.log"

# Create output directory
mkdir -p "${outdir}/${prefix}"

# Run
cd "${outdir}/${prefix}"
cmd="BUSCO_v1.1b1.py -in "$transcriptome_path" -l "${script_absdir}/main/lineage/vertebrata" -o "${prefix}" -f -c "$threads" -m "transcriptome""
echo "$cmd" | tee -a "$logfile"
eval "$cmd" | tee -a "$logfile"

