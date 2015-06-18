#!/usr/bin/env bash

set -e
shopt -s extglob # To work with regex

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0")"

#============== pathway based on the system ==================
# polyA/T reference file 
ADAPTER2="$script_absdir/main/polyA.fa"

# chrM fasta file
CMCCHRM="chrM.fa"   # Add the path to $BOWTIE_INDEXES

# total RNA fasta file including rhesus RRNA and mammamlian RRNA
RRNA="rrna_total.fa"    # Add the path to $BOWTIE_INDEXES   
#============== EOF pathway based on the system ==================


usage="
Description:
\n\tThe script is aimed to clean paired-end reads by adaptor, quality, polyA, rRNA and chrM.\n
\nUsage:
\n\t"$script_name" QUALSCORE THREADS INPUTPAIR1 INPUTPAIR2 LIBRARY\n
\nE.g.
\n\tfilteringPE.sh phred33 2 read_1.fastq.gz read_2.fastq.gz out\n
\nParmeters:
		\n\t1. Library is the prefix for the output of cleaned data.
		\n\t2. QualityScoreType could be phred33 or phred64.\n
\nBefore usage:
\n\t1. The script assume that the following softwares are in the path:
		\n\t\t1) flexbar
		\n\t\t2) bowtie
		\n\t\t3) samtools
\n\t2. Please change the variable of the scripts based on the pathway of the system:
		\n\t\t1) ADAPTER2
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

QUALSCORE=$1; shift
THREADS=$1; shift
INPUT1=$1; shift
INPUT2=$1; shift
LIBRARY=$1; shift
V4SCRATCH="$(dirname "$INPUT1")"    # Store the output in a subdirectory where the reads are
outdir="$V4SCRATCH/$LIBRARY"
mkdir -p "$outdir"

# important: quality score type for far and bowtie. 
# hard code defined variable:
FAR_FORMAT="sanger"
BOWTIE_QUAL="--phred33-quals"

getQual (){
   case $1 in
        "phred33") 
	  FAR_FORMAT="sanger"
	  BOWTIE_QUAL="--phred33-quals"
	  TRIMMOMATIC_FORMAT="phred33"
	;;
        "phred64")  
	  FAR_FORMAT="sanger"
	  BOWTIE_QUAL="--phred64-quals" 
	  TRIMMOMATIC_FORMAT="phred64"
	;;
   esac
}

# functions
fail () {
  echo "$1 step failed"
  exit 1
}

skip () {
  echo "$1 step skipped because already done."
}

# quality score type:
getQual $QUALSCORE

# Output prefixes
prefix1="$outdir/${LIBRARY}_F1"   # Files after flexbar
prefix2="$outdir/${LIBRARY}_F2"   # Files after chrM
prefix3="$outdir/${LIBRARY}_F3"   # Files after rRNA

# Count number of reads
total_lines1="$(zcat "$INPUT1"| wc -l)"
total_lines2="$(zcat "$INPUT2"| wc -l)"

total_reads1="$(($total_lines1/4))"
total_reads2="$(($total_lines2/4))"
echo "Processing total of $total_reads1 reads"

# [ PolyA/T trimming ]
echo "Poly dA/dT trimming..."

if [[ $RAN_POLYA || ! -s $POLYA_OUTPUT_FILE ]]; then
	flexbar --adapters "$ADAPTER2" -r "$INPUT1" -p "$INPUT2" \
	--target "$prefix1" \
	--format "$FAR_FORMAT" \
	--threads "$THREADS" \
	--max-uncalled 5 \
	--min-read-length 35 \
	--adapter-min-overlap 6 &>"$prefix1.log"\
	|| { rm -f "$prefix1"_{1,2}.fastq ; fail "PolyA removeing"; } 
	RAN_POLYA=1
	gzip "$prefix1"_1.fastq &
	gzip "$prefix1"_2.fastq &
	wait $! || exit $?
else
	skip "PolyA removeing"
fi

# Count actual number of reads
total_lines1="$(zcat "$prefix1"_1.fastq.gz | wc -l)"
total_lines2="$(zcat "$prefix1"_2.fastq.gz | wc -l)"

after_trimming_reads1="$(($total_lines1*25))"
after_trimming_reads2="$(($total_lines2*25))"
left_after_trimming_reads1="$(($after_trimming_reads1/$total_reads1))"
left_after_trimming_reads2="$(($after_trimming_reads2/$total_reads2))"
echo ""$left_after_trimming_reads1"% of reads left after trimming"


# [ ChrM filtering ]
# Indexes have to be generated beforehand.
echo "chrM filtering..."

bowtie "$BOWTIE_QUAL" -Sq -v 2 -m 1 -X 500 --un "$prefix2.fastq" -p "$THREADS" "$CMCCHRM" \
  -1 <(zcat ""$prefix1"_1.fastq.gz") -2 <(zcat ""$prefix1"_2.fastq.gz") 2>"$prefix2".log | samtools view -S -b /dev/stdin >  "$prefix2".bam
gzip "$prefix2"_1.fastq &
gzip "$prefix2"_2.fastq &
wait $! || exit $?

# Get rid of intermediate files
rm "$outdir"/*_F1_*fastq.gz

# Count actual number of reads
total_lines1="$(zcat "$prefix2"_1.fastq.gz | wc -l)"
total_lines2="$(zcat "$prefix2"_2.fastq.gz | wc -l)"

after_chrM_reads1="$(($total_lines1*25))"
after_chrM_reads2="$(($total_lines2*25))"
left_after_chrM_reads1="$(($after_chrM_reads1/$total_reads1))"
left_after_chrM_reads2="$(($after_chrM_reads2/$total_reads2))"
echo ""$left_after_chrM_reads1"% of reads left after chrM filtering"

# [ rRNA filtering ]
# Indexes have to be generated beforehand.
echo "rRNA filtering..."

bowtie "$BOWTIE_QUAL" -Sq -v 2 -m 1 -X 500 --un "$prefix3.fastq" --threads "$THREADS" "$RRNA" \
  -1 <(zcat ""$prefix2"_1.fastq.gz") -2 <(zcat ""$prefix2"_2.fastq.gz") 2>"$prefix3".log | samtools view -S -b /dev/stdin > "$prefix3".bam
gzip "$prefix3"_1.fastq &
gzip "$prefix3"_2.fastq &
wait $! || exit $?

# Get rid of intermediate files
rm "$outdir"/*_F2_*.fastq.gz

# Count actual number of reads
total_lines1="$(zcat "$prefix3"_1.fastq.gz | wc -l)"
total_lines2="$(zcat "$prefix3"_2.fastq.gz | wc -l)"

after_rRNA_reads1="$(($total_lines1*25))"
after_rRNA_reads2="$(($total_lines2*25))"
left_after_rRNA_reads1="$(($after_rRNA_reads1/$total_reads1))"
left_after_rRNA_reads2="$(($after_rRNA_reads2/$total_reads2))"
echo ""$left_after_rRNA_reads1"% of reads left after rRNA filtering"

# [ program end ]
