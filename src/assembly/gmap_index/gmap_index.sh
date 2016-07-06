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

TEMP=$(getopt -o ht:i: -l help,threads:,maxIntron: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
threads=1
maxIntron=50

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
    -i|--maxIntron)	
      maxIntron="$2"
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
coreGenes="$2"
outdir="$3"

## Setting some file/dirnames
assemblyID="$(basename "$assembly")"
prefixAssembly="${assemblyID%%.*}"
logfile="${PWD}/${prefixAssembly}_cegmaOut.log"
echo "$(date): Starting ..." | tee -a "$logfile"

## Create general output directory
mkdir -p "$outdir"

# Gunzip assembly in case it's compressed
if [[ "$assembly" =~ \.gz$ ]];
then
  echo "$(date): Uncompressing assembly ..." | tee -a "$logfile"
  gunzip "$assembly"
  assemblyFile="${assembly%".gz"}"
  compress='x'
else
  assemblyFile="$assembly"
fi

# Run cegma
echo "$(date): Running CEGMA ..." | tee -a "$logfile"
outPrefix="${outdir}/${prefixAssembly}"
cegma --max_intron "$maxIntron" --vrt --mam \
  --threads "$threads" \
  -g "$assemblyFile" \
  -p "$coreGenes" \
  -o "$outPrefix" &>>"$logfile"

# Compressing the .fasta file again in case it was
if [ "$compress" ];
then
  echo "$(date): Compressing the assembly again ..." | tee -a "$logfile"
  gzip "$assemblyFile"
fi

# Done
echo "$(date): Done" | tee -a "$logfile"

