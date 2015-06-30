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

TEMP=$(getopt -o ht: -l help,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

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
assembly="$1"
reference="$2"
read1="$3"
read2="$4"
outdir="$5"

## Setting some file/dirnames
assemblyFile="$(basename "$assembly")"
referenceFile="$(basename "$reference")"
assemblyDir="$(dirname "$assembly")"
referenceDir="$(dirname "$reference")"
prefixAssembly="${assemblyFile%.*}"
prefixReference="${referenceFile%.*}"
logfile="${PWD}/${prefixAssembly}_refEvalPEOut.log"

## Create general output directory
mkdir -p "$outdir"

## Run blat to compute alignment-based scores
# Blat output directory
outdirBlat="${outdir}/blat"
mkdir -p "$outdirBlat"
# Output files
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
# Output files 1
refFileAssembly="${outdirRsem}/${prefixAssembly}_ref"
refFileReference="${outdirRsem}/${prefixReference}_ref"
# Run rsem
echo "$(date): Starting RSEM ..." | tee -a "$logfile"
rsem-prepare-reference "$assembly" "$refFileAssembly" &>>"$logfile"
rsem-prepare-reference "$reference" "$refFileReference" &>>"$logfile"
exit 0
# Output files 2
exprFileAssembly="${outdirRsem}/${prefixAssembly}_expr"
exprFileReference="${outdirRsem}/${prefixReference}_expr"
rsem-calculate-expression -p "$threads" --no-bam-output "$read1" "$refFileAssembly" "$exprFileAssembly" &>>"$logfile"
rsem-calculate-expression -p "$threads" --no-bam-output "$read1" "$refFileReference" "$exprFileReference" &>>"$logfile"


ref-eval --scores=nucl,pair,contig,kmer,kc \
             --weighted=both \
             --A-seqs "$assembly" \
             --B-seqs "$reference" \
             --A-expr A_expr.isoforms.results \
             --B-expr B_expr.isoforms.results \
             --A-to-B "$blatOutAtoR" \
             --B-to-A "$blatOutRtoA" \
             --num-reads 5000000 \
             --readlen 76 \
             --kmerlen 76 \
             | tee scores.txt


# Copy logfile to working directory
cp "$logfile" ./
