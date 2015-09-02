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
transcript_file="$1"
exon_file="$2"
transcript_basename="$(basename ${transcript_file})"

# Output file and Logfile
prefix="${transcript_basename%%.*}"
prefix_outfile="${outdir}/${prefix}_"
logfile="${PWD}/${prefix}.log"

# Create output directory
mkdir -p "$outdir"
touch "$logfile"

# Run
# blastn output fields: query id, subject ids, % identity, alignment length,
# mismatches, gap opens, q. start, q. end, s. start, s. end, evalue, bit score
# We probably want to add an intermediate script between blastn and groupBy that
# filters the result accoring to some criteria. E.g. if more than one contig have
# the same exon combination get the one with lowest e-value.
echo "$(date): Starting blastn ..." | tee -a "$logfile"
blastn -outfmt 6 -num_threads "$threads" -subject "$exon_file" \
    -query "$transcript_file" 2>>"$logfile" \
    | cut -f 1,2,11 \
    | groupBy -g 1 -c 2,3 -o collapse,collapse \
    | "$perl_script" "$transcript_file" "$prefix_outfile"

# Done
echo "$(date): Done." | tee -a "$logfile"
exit 1
