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

TEMP=$(getopt -o h -l help -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ]
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults

while true
do
  case "$1" in
    -h|--help)			
      cat "$script_absdir/${script_name}_help.txt"
      exit
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

# Prefix of the target logfiles
prefix="$1"

# Print colum names
printf "Library\tinitial_reads\tafter_polyAT\tafter_chrM\tafter_rRNA\tfinal_reads\n" > "summary_${prefix}.log"

# Parse logfiles
for f in "${prefix}"*;
do
  # Get library name
  temp="${f%*.log}"
  library="${temp#${prefix}_}"
  # Parse number of initial reads
  initial_reads="$(cat "$f" | sed -n -e 's/Processing total of //p' | sed -n -e 's/ reads//p')"
  printf "${library}\t${initial_reads}"
  # Reads after each filter
  percentages="$(cat "$f" | grep %)"
  while read line; do 
    temp="\t${line::2}"
    printf "${temp}%%"
  done < <(echo "$percentages")
  # Total reads in the end
  final_reads="$(cat "$f" | sed -n -e 's/^.*Done, //p' | sed -n -e 's/ reads.*$//p')"
  printf "\t$final_reads"
  # New line
  printf "\n"
done >> "summary_${prefix}.log"

