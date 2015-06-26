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

TEMP=$(getopt -o ht:er -l help,threads:,eval,ref -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
threads=1
averageLength=75

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
fastaPath="$3"
fastaFile="$(basename "$fastaPath")"
fastaDir="$(dirname "$fastaPath")"

# Setting some file/dirnames
outdir="${fastaDir}/detonateOut"
prefix="${fastaFile%".fasta"}"
transcriptLengthParameters="${fastaDir}/${prefix}_length_distribution/${prefix}.txt"
logfile="${outdir}/${prefix}_detonateRsem.log"

# Gunzip in parallel
# Process substitution doesn't work with Seecer, i.e. <(zcat read)
gunzip "$read1" &
gunzip "$read2" &
wait %1 %2 || exit $?
fqFile1="${read1%".gz"}"
fqFile2="${read2%".gz"}"

# Find contig length distribution if still doesn't exist
if [ ! -f "$transcriptLengthParameters" ]
then
  mkdir -p "$(dirname "$transcriptLengthParameters")"
  rsem-eval-estimate-transcript-length-distribution "$fastaPath" "$transcriptLengthParameters"
fi

# Evaluation
if [ "$eval" ]
then
  # Create output directory
  mkdir -p "$outdir"
  # Run
  rsem-eval-calculate-score -p "$threads" --transcript-length-parameters "$transcriptLengthParameters" \
    --paired-end "$fqFile1" "$fqFile2" "$fastaPath" "${outdir}/${prefix}" "$averageLength"  &>"$logfile"
fi

# Compress the fastq files again
gzip "$fqFile1" &
gzip "$fqFile2" &
wait %1 %2 || exit $?


