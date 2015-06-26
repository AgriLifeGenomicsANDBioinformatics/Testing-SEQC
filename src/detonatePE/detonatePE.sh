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

TEMP=$(getopt -o hd:er -l help,outdir:,eval,ref -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir=./
threads=1
averageLength=75

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
    -e|--eval)	
      eval=x
      shift 1
      ;;
    -r|--ref)	
      ref=x
      shift 1
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
fastaFile="$3"

# Setting some file/dirnames
prefix="${fastaFile%".fasta"}"
transcriptLengthParameters="${prefix}_length_distribution"

# Gunzip in parallel
# Process substitution doesn't work with Seecer, i.e. <(zcat read)
gunzip "$read1" &
gunzip "$read2" &
wait %1 %2 || exit $?
fqFile1="$(basename "$read1" .gz)"
fqFile2="$(basename "$read2" .gz)"

# Find contig length distribution if still doesn't exist
if [ ! -f "$transcriptLengthParameters" ]
then
  mkdir -p "$transcriptLengthParameters"
  rsem-eval-estimate-transcript-length-distribution "$fastaFile" "$transcriptLengthParameters/${prefix}.txt"
fi

# Evaluation
if [ "$eval" ]
then
  # Create output directories
  mkdir -p "$prefix"
  rsem-eval-calculate-score --no-qualities -p "$threads" --transcript-length-parameters "$transcriptLengthParameters/${prefix}.txt" \
    --paired-end "$fqFile1" "$fqFile2" "$fastaFile" "$prefix" "$averageLength" &>"${prefix}/${prefix}_detonateRsem.log"
fi

# Compress the fastq files again
gzip "$fqFile1" &
gzip "$fqFile2" &
wait %1 %2 || exit $?
