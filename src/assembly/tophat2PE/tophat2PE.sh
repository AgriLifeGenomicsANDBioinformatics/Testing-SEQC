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

TEMP=$(getopt -o ht:k: -l help,threads:,kmerSize: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Environment variables
bowtie_indexes="$BOWTIE2_INDEXES"

# Defaults
threads=1

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

## Read input files
reference="$1"
read1="$2"
read2="$3"
outdir="$4"

## Logfile
referenceFile="$(basename "$reference")"
prefixReference="${referenceFile%.*}"
logfile="${PWD}/${prefixReference}_tophat2PEOut.log"
echo "$(date): Starting ..." | tee -a "$logfile"

## Reference and index path
referenceAbsPath="$(realpath "$reference")"
referenceDir="$(dirname "$referenceAbsPath")"
referenceIndex="${referenceAbsPath%.*}"
bowtie2Index="${bowtie_indexes}/${prefixReference}"

## Temp dir for tophat2
## One for each assembly when working in parallel
temp="${PWD}/${prefixReference}_temp"
mkdir -p "$temp"

## Create general output directory
## Tophat doesn't allow you to assign a prefix to the output
## There is the need to create a folder for each assembly within the general output directory
outPrefix="${outdir}/${prefixReference}_out"
mkdir -p "$outPrefix"

# Generate bowtie indexes
if [ ! -f "${bowtie2Index}.1.bt2" ];
then
  echo "$(date): Building bowtie indexes ..." | tee -a "$logfile"
  bowtie2-build -fq "$referenceAbsPath" "$bowtie2Index" &>>"$logfile"
else
  echo "$(date): Indexes for bowtie2 found in ${bowtie_indexes}..." | tee -a "$logfile"
fi

# Check whether the reads are compressed
if [[ "$read1" =~ \.gz$ ]] && [[ "$read2" =~ \.gz$ ]] ;
then
  echo "$(date): Uncompressing fastq files ..." | tee -a "$logfile"
  gunzip "$read1" &
  gunzip "$read2" &
  wait %1 %2 || exit $?
  fqFile1="${read1%".gz"}"
  fqFile2="${read2%".gz"}"
else
  echo "$(date): Files were already uncompressed..." | tee -a "$logfile"
  fqFile1="${read1}"
  fqFile2="${read2}"
fi

# Run tophat2
echo -e "$(date): Running tophat2 ..." | tee -a "$logfile"
tophat2 -p "$threads" -o "$outPrefix" --tmp-dir "$temp" "$bowtie2Index" "$fqFile1" "$fqFile2" &>>"$logfile" 

# Compress reads again
echo "$(date): Compressing fastq files ..." | tee -a "$logfile"
gzip "$fqFile1" &
gzip "$fqFile2" &
wait %1 %2 || exit $?

# Done
echo "$(date): Done." | tee -a "$logfile"

