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

# Defaults
threads=1
kmerSize=25

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
    -k|--kmerSize)	
      kmerSize="$2"
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
assembly="$1"
reference="$2"
read1="$3"
read2="$4"
outdir="$5"

## Setting some file/dirnames
assemblyFile="$(basename "$assembly")"
referenceFile="$(basename "$reference")"
assemblyDir="$(realpath "$assembly")"
referenceDir="$(realpath "$reference")"
prefixAssembly="${assemblyFile%.*}"
prefixReference="${referenceFile%.*}"
logfile="${PWD}/${prefixAssembly}_refEvalPEOut.log"
echo "$(date): Starting ..." | tee -a "$logfile"

## Create general output directory
mkdir -p "$outdir"

## Run blat to compute alignment-based scores
# Blat output directory
outdirBlat="${outdir}/blat"
mkdir -p "$outdirBlat"
# Output files BLAT
blatOutAtoR="${outdirBlat}/${prefixAssembly}ToRef.psl"
blatOutRtoA="${outdirBlat}/refTo${prefixAssembly}.psl"
# Run Blat
echo "$(date): Starting BLAT ..." | tee -a "$logfile"
blat -minIdentity=80 "$reference" "$assembly" "$blatOutAtoR" &>>"$logfile"
blat -minIdentity=80 "$assembly" "$reference" "$blatOutRtoA" &>>"$logfile"

## Prepare reference
# rsem output directory
outdirRsem="${outdir}/rsem"
mkdir -p "$outdirRsem"

# Output files rsem-prepare-reference
refFileAssembly="${outdirRsem}/${prefixAssembly}_ref"
refFileReference="${outdirRsem}/${prefixReference}_ref"

# Run rsem
echo "$(date): Starting RSEM ..." | tee -a "$logfile"
rsem-prepare-reference "$assembly" "$refFileAssembly" &>>"$logfile"
rsem-prepare-reference "$reference" "$refFileReference" &>>"$logfile"

# Generate bowtie indexes
echo "$(date): Building bowtie indexes ..." | tee -a "$logfile"
transcriptsAssembly="${refFileAssembly}.transcripts.fa"
transcriptsReference="${refFileReference}.transcripts.fa"

bowtie-build -fq "$transcriptsAssembly" "$refFileAssembly" &>>"$logfile"
bowtie-build -fq "$transcriptsReference" "$refFileReference" &>>"$logfile"

# Check whether the reads are compressed
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

# Output files rsem-calculate-expression
echo "$(date): Calculating expression ..." | tee -a "$logfile"
exprFileAssembly="${outdirRsem}/${prefixAssembly}_expr"
exprFileReference="${outdirRsem}/${prefixReference}_expr"

rsem-calculate-expression -p "$threads" --no-bam-output --paired-end "$fqFile1" "$fqFile2" "$refFileAssembly" "$exprFileAssembly" &>>"$logfile"
rsem-calculate-expression -p "$threads" --no-bam-output --paired-end "$fqFile1" "$fqFile2" "$refFileReference" "$exprFileReference" &>>"$logfile"

# rsem output directory
outdirRef="${outdir}/ref"
mkdir -p "$outdirRef"

# Scores file
scoreFile="${outdirRef}/${prefixAssembly}_${prefixReference}_refEvalPE.txt"

# Get number of reads
echo "$(date): Computing number of reads ..." | tee -a "$logfile"
n="$(cat "$fqFile1" | wc -l)"
numReads="$(( ($n-1)/4 ))"

# Get average length of the first 100 reads in fq file
echo "$(date): Computing average read length ..." | tee -a "$logfile"
averageReadLength=0
for i in {2..400..4};
do
  n="$(sed -n ${i}p "$fqFile1" | wc -c)"
  averageReadLength="$(( $n + $averageReadLength - 1 ))"
done
averageReadLength="$(($averageReadLength/100))"

# Compute score
echo "$(date): Computing scores ..." | tee -a "$logfile"
isoformsAssembly="${exprFileAssembly}.isoforms.results"
isoformsReference="${exprFileReference}.isoforms.results"

ref-eval --scores=nucl,pair,contig,kmer,kc \
             --weighted=both \
             --A-seqs "$assembly" \
             --B-seqs "$reference" \
             --A-expr "$isoformsAssembly" \
             --B-expr "$isoformsReference" \
             --A-to-B "$blatOutAtoR" \
             --B-to-A "$blatOutRtoA" \
             --num-reads "$numReads" \
             --readlen "$averageReadLength" \
             --kmerlen "$kmerSize" 1>"$scoreFile" &>>"$logfile"

echo "$(date): Done" | tee -a "$logfile"

