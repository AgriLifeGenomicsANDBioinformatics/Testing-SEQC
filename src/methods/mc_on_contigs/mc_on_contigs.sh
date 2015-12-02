#!/usr/bin/env bash
# ------------------------------------------------------------------------------
##The MIT License (MIT)
##
##Copyright (c) 2015 Jordi Abante
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
# ------------------------------------------------------------------------------
shopt -s extglob

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0" .sh)"

# Find scripts
perl_script="${script_absdir}/perl/${script_name}.pl"
R_script="${script_absdir}/R/${script_name}.R"

if [ $# -eq 0 ]
    then
        cat "$script_absdir/${script_name}_help.txt"
        exit 1
fi

TEMP=$(getopt -o hd:t: -l help,outdir:,threads: -n "$script_name.sh" -- "$@")

if [ $? -ne 0 ] 
then
  echo "Terminating..." >&2
  exit -1
fi

eval set -- "$TEMP"

# Defaults
outdir="$PWD"
threads=2
kmer_size=2

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
      exit -1
      ;;  
  esac
done

# Start time
start_time="$(date +"%m")"
>&2 echo "$(date --rfc-3339=seconds): Starting ..."

# Inputs
transcriptome_path="$1"

# Output
transcriptome_abspath="$(readlink -e "${transcriptome_path}" )"
transcriptomes="$(ls "${transcriptome_abspath}" | grep .fa*)"
n="$(echo "${transcriptomes}" | wc -l)"
>&2 echo "$(date --rfc-3339=seconds): ${n} transcriptomes being processed..."

# Output directory
mkdir -p "$outdir"

### Run perl script
## Export variables
export perl_script
export transcriptome_abspath
export kmer_size

## Run using N threads
echo "${transcriptomes}" | xargs -I {} --max-proc "$threads" bash -c \
    ''${perl_script}' '${transcriptome_abspath}/{}' '${kmer_size}'| gzip > '${outdir}/{}_mc.gz''

## Time elapsed
end_time="$(date +"%m")"
>&2 echo "$(date --rfc-3339=seconds): Time elapsed after building Transition Matrices: $(( $end_time - $start_time )) m"

## Run R script
echo "${transcriptomes}" | xargs -I {} --max-proc "$threads" bash -c \
    ''${R_script}' '${outdir}/{}_mc.gz' '${outdir}/{}_ssd.txt''
#
## Time elapsed
end_time="$(date +"%m")"
>&2 echo "$(date --rfc-3339=seconds): Done. Total time elapsed: "$(( $end_time - $start_time ))" m"
