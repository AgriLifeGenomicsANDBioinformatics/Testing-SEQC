#!/usr/bin/env bash

set -e
shopt -s extglob # To work with regex

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0")"

#============== pathway based on the system ==================
# polyA/T reference file 
polyAT="$script_absdir/main/polyA.fa"

# chrM fasta file
CMCCHRM="chrM.fa"   # Add the path to $BOWTIE_INDEXES

# total RNA fasta file including rhesus RRNA and mammamlian RRNA
RRNA="rrna_total.fa"    # Add the path to $BOWTIE_INDEXES   
#============== EOF pathway based on the system ==================


usage="
Description:
\n\tThe script is aimed to clean paired-end reads by poly dA/dT tails, rRNA and chrM.\n
\nUsage:
\n\t"$script_name" QUAL THREADS INPUTPAIR_R1 INPUTPAIR_R2 OUTDIR\n
\nE.g.
\n\tfilteringPE.sh sanger 2 read_1.fastq.gz read_2.fastq.gz filteringPEOut1\n
\n\tfilteringPE.sh i.18 3 read_1.fastq.gz read_2.fastq.gz filteringPEOut2\n
\nBefore usage:
\n\t1. The script assume that the following softwares are in the path:
		\n\t\t1) flexbar
		\n\t\t2) bowtie
		\n\t\t3) samtools
\n\t2. Please change the variable of the scripts based on the pathway of the system:
		\n\t\t1) polyAT
		\n\t\t3) CHRM
		\n\t\t4) RRNA	
\nOutput:
		\n\t1) F1: reads that pass polyA trimming
		\n\t2) F2: reads that pass chrM filtering
		\n\t3) F3: reads that pass rRNA filtering
		\n
"

if [ $# -ne 5 ]
    then
        echo -e $usage >&2
        exit 1
fi

# Read inputs
QUAL=$1; shift
THREADS=$1; shift
INPUT1=$1; shift
INPUT2=$1; shift
outdir=$1;shift

# Get the library name and create the output directory
read1="$(basename "$INPUT1")"
read2="$(basename "$INPUT2")"
lcprefix="$(printf "%s\n" "$read1" "$read2" | sed -e 'N;s/^\(.*\).*\n\1.*$/\1/')"
LIBRARY="${lcprefix%_[rR]}"

mkdir -p "$outdir"

# Log file with timestamp
script_name_prefix="$(basename "$0" .sh)"
LOGFILE="${PWD}/${script_name_prefix}_${LIBRARY}.log"
touch "$LOGFILE"        # For general .log file 

# functions
fail () {
  echo "$1 step failed"
  exit 1
}

skip () {
  echo "$1 step skipped because already done."
}

# Run
echo "$(date): Starting..." | tee -a "$LOGFILE"

# Output prefixes
prefix1="${outdir}/${LIBRARY}_F1"   # Files after flexbar
prefix2="${outdir}/${LIBRARY}_F2"   # Files after chrM
prefix3="${outdir}/${LIBRARY}_F3"   # Files after rRNA

# Count number of reads
total_lines1="$(zcat "$INPUT1"| wc -l)"
total_lines2="$(zcat "$INPUT2"| wc -l)"

total_reads1="$(($total_lines1/4))"
total_reads2="$(($total_lines2/4))"
echo "Processing total of ${total_reads1} reads" | tee -a "$LOGFILE"

# [ PolyA/T trimming ]
echo "$(date): Poly dA/dT trimming..." | tee -a "$LOGFILE"

flexbar --adapters "$polyAT" -r "$INPUT1" -p "$INPUT2" \
--target "$prefix1" \
--format "$QUAL" \
--threads "$THREADS" \
--max-uncalled 5 \
--min-read-length 50 \
--adapter-min-overlap 6 &>"${prefix1}.log"\
|| { rm -f ${prefix1}_{1,2}.fastq ; fail "PolyA removeing"; } 

gzip "${prefix1}_1.fastq" &
gzip "${prefix1}_2.fastq" &
wait %1 %2 || exit $?

# Count actual number of reads
total_lines1="$(zcat "${prefix1}_1.fastq.gz" | wc -l)"
total_lines2="$(zcat "${prefix1}_2.fastq.gz" | wc -l)"

after_trimming_reads1="$(($total_lines1*25))"
after_trimming_reads2="$(($total_lines2*25))"
left_after_trimming_reads1="$(($after_trimming_reads1/$total_reads1))"
left_after_trimming_reads2="$(($after_trimming_reads2/$total_reads2))"
echo "${left_after_trimming_reads1}% of original reads left after trimming" | tee -a "$LOGFILE"

# [ ChrM filtering ]
# Indexes have to be generated beforehand.
echo "$(date): chrM filtering..."| tee -a "$LOGFILE" 

bowtie -Sq -v 2 -m 10 -X 1000 --un "${prefix2}.fastq" -p "$THREADS" "$CMCCHRM" \
  -1 <(zcat "${prefix1}_1.fastq.gz") -2 <(zcat "${prefix1}_2.fastq.gz") 2>"${prefix2}.log" | samtools view -S -b /dev/stdin > "${prefix2}.bam"
gzip "${prefix2}_1.fastq" &
gzip "${prefix2}_2.fastq" &
wait %1 %2 || exit $?

# Get rid of intermediate files
rm "${outdir}"/*_F1_*fastq.gz

# Count actual number of reads
total_lines1="$(zcat "${prefix2}_1.fastq.gz" | wc -l)"
total_lines2="$(zcat "${prefix2}_2.fastq.gz" | wc -l)"

after_chrM_reads1="$(($total_lines1*25))"
after_chrM_reads2="$(($total_lines2*25))"
left_after_chrM_reads1="$(($after_chrM_reads1/$total_reads1))"
left_after_chrM_reads2="$(($after_chrM_reads2/$total_reads2))"
echo "${left_after_chrM_reads1}% of original reads left after chrM filtering" | tee -a "$LOGFILE"

# [ rRNA filtering ]
# Indexes have to be generated beforehand.
echo "$(date): rRNA filtering..." | tee -a "$LOGFILE"

bowtie -Sq -v 2 -m 10 -X 1000 --un "${prefix3}.fastq" --threads "$THREADS" "$RRNA" \
  -1 <(zcat "${prefix2}_1.fastq.gz") -2 <(zcat "${prefix2}_2.fastq.gz") 2>"${prefix3}.log" | samtools view -S -b /dev/stdin > "${prefix3}.bam"
gzip "${prefix3}_1.fastq" &
gzip "${prefix3}_2.fastq" &
wait %1 %2 || exit $?

# Get rid of intermediate files
rm "${outdir}"/*_F2_*.fastq.gz

# Count actual number of reads
total_lines1="$(zcat ${prefix3}_1.fastq.gz | wc -l)"
total_lines2="$(zcat ${prefix3}_2.fastq.gz | wc -l)"

after_rRNA_reads1="$(($total_lines1*25))"
after_rRNA_reads2="$(($total_lines2*25))"
left_after_rRNA_reads1="$(($after_rRNA_reads1/$total_reads1))"
left_after_rRNA_reads2="$(($after_rRNA_reads2/$total_reads2))"
echo "${left_after_rRNA_reads1}% of original reads left after rRNA filtering" | tee -a "$LOGFILE"
echo "$(date): Done, $(($total_lines1/4)) reads passed all the filters." | tee -a "$LOGFILE"

# [ program end ]
