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
hits_directory="$1"

# Output file and Logfile
prefix="${transcriptomes}"
logfile="${PWD}/${prefix}.log"

# Create output directory
mkdir -p "$outdir"
touch "$logfile"

# Detect all combinations
combinations="$(ls ${hits_directory} | sed -s 's/.*_//g;s/.fa//g' | sort | uniq )"

# Collapse files
while read line
do  
    cat ${hits_directory}/*_${line}.fa > ${outdir}/${line}_homologous.fa
done < <(echo "$combinations")

# Done
echo "$(date): Done." | tee -a "$logfile"
