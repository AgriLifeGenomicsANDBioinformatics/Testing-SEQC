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

TEMP=$(getopt -o ho: -l help,outdir: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outfile="${PWD}/catListOut.txt"

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
      ;;
    -o|--outfile)			
      outfile="$2"
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
list="$1"

## Create general output directory
outdir="$(dirname "$outfile")"
outBase="$(basename "$outfile")"
prefix="${outBase%%.*}"
mkdir -p "$outdir"

# Concatenate files
while read line; do 
    # Get the dir
    fileDir="$(dirname "$list")"
    file="${fileDir}/${line}"
    echo "$(date): Concatenating ${file} ..."
    # Cat the file
    if [[ "$file" =~ \.gz$ ]];
    then
      zcat "$file" >> "$outfile" 
    else
      cat "$file" >> "$outfile" 
    fi
done < "$list" 

# Compress the file
echo "$(date): Compressing output file ..." 
gzip "$outfile"

# Done
echo "$(date): Done" 

