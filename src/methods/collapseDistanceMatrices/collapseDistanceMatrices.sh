#!/usr/bin/env bash
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd: -l help,outdir: -n "$script_name.sh" -- "$@")

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
        cat "$script_absdir"/${script_name}_help.txt
        exit
        ;;  
    -d|--outdir)
        outdir="$2"
        shift 2
        ;;  
    --) 
        shift
        break
        ;;  
    *)  
        echo "$script_name.sh:Internal error!"
        exit -1
        ;;  
    esac
done

# Output
prefix="$(less_common_prefix.sh "$@")"
outfile="${outdir}/${prefix}_dm.txt"

# Output directory
mkdir -p "$outdir"

# R command
Rscript "${script_absdir}/R/${script_name}.R" "$@" "$outfile" # &>/dev/null
