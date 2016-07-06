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
averageReadLength=75

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
blat -minIdentity=80 "$reference" "$assembly" "$blatOutAtoR"
blat -minIdentity=80 "$assembly" "$reference" "$blatOutRtoA"

## Prepare reference
# rsem output directory
outdirRsem="${outdir}/rsem"
mkdir -p "$outdirRsem"

# Output files rsem-prepare-reference
refFileAssembly="${outdirRsem}/${prefixAssembly}"
refFileReference="${outdirRsem}/${prefixReference}"

# Run rsem
echo "$(date): Starting RSEM ..." | tee -a "$logfile"
rsem-prepare-reference --no-polyA "$assembly" "$refFileAssembly"
rsem-prepare-reference --no-polyA "$reference" "$refFileReference"

# Generate bowtie indexes in BOWTIE2_INDEXES
#echo "$(date): Building ${prefixAssembly} bowtie index ..." | tee -a "$logfile"
#transcriptsAssembly="${refFileAssembly}.transcripts.fa"
#transcriptsReference="${refFileReference}.transcripts.fa"
#bowtie2-build -fq "$transcriptsAssembly" "$refFileAssembly"
#
#if [ -e "${refFileReference}.1.bt2" ];
#then 
#  echo "$(date): Reference index found in ${outdirRsem}..." | tee -a "$logfile"
#else
#  echo "$(date): Building ${prefixReference} bowtie index ..." | tee -a "$logfile"
#  bowtie2-build -fq "$transcriptsReference" "$refFileReference"
#fi
#
## Check whether the reads are compressed
#if [[ "$read1" =~ \.gz$ ]] && [[ "$read2" =~ \.gz$ ]] ;
#then
#  gunzip "$read1" &
#  gunzip "$read2" &
#  wait %1 %2 || exit $?
#  fqFile1="${read1%".gz"}"
#  fqFile2="${read2%".gz"}"
#else
#  fqFile1="${read1}"
#  fqFile2="${read2}"
#fi
#
## Output files rsem-calculate-expression
#echo "$(date): Calculating expression ..." | tee -a "$logfile"
#exprFileAssembly="${outdirRsem}/${prefixAssembly}_expr"
#exprFileReference="${outdirRsem}/${prefixReference}_expr"
#
#rsem-calculate-expression -p "$threads" --no-bam-output --bowtie2 --paired-end "$fqFile1" "$fqFile2" "$refFileAssembly" "$exprFileAssembly"
#rsem-calculate-expression -p "$threads" --no-bam-output --bowtie2 --paired-end "$fqFile1" "$fqFile2" "$refFileReference" "$exprFileReference"
#
## rsem output directory
#outdirRef="${outdir}/ref"
#mkdir -p "$outdirRef"
#
## Scores file
#scoreFile="${outdirRef}/${prefixAssembly}_${prefixReference}_refEvalPE.txt"
#
## Get number of reads
#echo "$(date): Computing number of reads ..." | tee -a "$logfile"
#n="$(cat "$fqFile1" | wc -l)"
#numReads="$(( ($n-1)/4 ))"
#
## Compute score
#echo "$(date): Computing scores ..." | tee -a "$logfile"
#isoformsAssembly="${exprFileAssembly}.isoforms.results"
#isoformsReference="${exprFileReference}.isoforms.results"
#
#ref-eval --scores=nucl,pair,contig,kmer,kc \
#             --weighted=both \
#             --A-seqs "$assembly" \
#             --B-seqs "$reference" \
#             --A-expr "$isoformsAssembly" \
#             --B-expr "$isoformsReference" \
#             --A-to-B "$blatOutAtoR" \
#             --B-to-A "$blatOutRtoA" \
#             --num-reads "$numReads" \
#             --readlen "$averageReadLength" \
#             --kmerlen "$kmerSize" 1>"$scoreFile" 2>>"$logfile"
#
## Copy scores to the logfile
#cat "$scoreFile" >> "$logfile"
#
## Create symlinks bowtie2 indexes
#echo "$(date): Refreshing symlinks for bowtie2 indexes in ${bowtie_indexes} ..." | tee -a "$logfile"
#for f in ${outdirRsem}/*bt2;
#do
#  name="$(basename "$f")"
#  symlink="${bowtie_indexes}/${name}" 
#  fullpath="$(realpath "$f")"
#  if [ -e "$symlink" ];
#  then
#    rm "$symlink"
#    ln -fs "$fullpath" "$symlink"
#  else 
#    ln -fs "$fullpath" "$symlink"
#  fi
#done
#
## Done
#echo "$(date): Done" | tee -a "$logfile"
#
