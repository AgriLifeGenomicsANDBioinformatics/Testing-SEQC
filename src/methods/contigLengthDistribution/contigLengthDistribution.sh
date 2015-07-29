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
contigs_file="$1"
contigs_name="$(basename "$contigs_file")"

# Output file and Logfile
prefix="${contigs_name%%.*}"
outfile_txt="${outdir}/${prefix}_cld.txt"
outfile_pdf="${outdir}/${prefix}_cld.pdf"

# Create output directory
mkdir -p "$outdir"

# Run
# Parsing the file
nreads=0
while read line;
do 
    length="$(echo "$line" | wc -c )"
    ((length-1))
    printf "${length}\t1\n"
    nreads="$((nreads+1))"
done < <(zcat -f "$contigs_file" | grep -v "^>") | \
    sort -k 1,1n |\
    groupBy -g 1 -c 2 -o sum > "$outfile_txt"

# R command to generate the plot
Rscript "${script_absdir}/R/${script_name}.R" "$outfile_txt" "$outfile_pdf" "$prefix" &>/dev/null
rm -f "Rplots.pdf"
