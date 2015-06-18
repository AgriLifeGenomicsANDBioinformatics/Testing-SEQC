#!/usr/bin/env bash

# This shebang make the code more portable.
# Sometimes you don't know where bash, perl or python is...

set -e

# Recommended to work with regex
shopt -s extglob

# Maybe the code is being called from a symbolic link (e.g. bin folder insted of src)
abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0")"

#============== pathway based on the system ==================
# picard samtofastq.jar file path
#SAMTOFASTQ="/v4scratch/lp364/SamToFastq.jar"
SAMTOFASTQ="$script_absdir/SamToFastq.jar"

# paired-end data adaptor file
#ADAPTER=/v4scratch/lp364/adaptorpe.fa    # Not necessary

# polyA/T reference file 
#ADAPTER2=/v4scratch/lp364/polyA.fa
ADAPTER2="$script_absdir/main/polyA.fa"

# chrM fasta file
#CMCCHRM=/v4scratch/lp364/bowtie-0.12.8/indexes/CMC_chrMidx
CMCCHRM="chrM.fa"   # Add the path to $BOWTIE_INDEXES

# total RNA fasta file including rhesus RRNA and mammamlian RRNA
#RRNA=/v4scratch/lp364/bwa-0.6.2/Rfambwaidx
#V4SCRATCH=/v4scratch/lp364
RRNA="rrna_total.fa"    # Add the path to $BOWTIE_INDEXES   
#============== EOF pathway based on the system ==================


usage="
Description:
\n\tThe script is aimed to clean paired-end reads by adaptor, quality, polyA, rRNA and chrM.\n
\nUsage:
\n\t"$script_name" QUALSCORE THREADS INPUTPAIR1 INPUTPAIR2 LIBRARY\n
\nParmeters:
		\n\t1. Library is the prefix for the output of cleaned data.
		\n\t2. QualityScoreType could be phred33 or phred64.\n
\nBefore usage:
\n\t1. The script assume that the following softwares are in the path:
		\n\t\t1) flexbar
		\n\t\t2) bowtie
\n\t2. Please change the variable of the scripts based on the pathway of the system:
		\n\t\t1) SAMTOFASTQ
		\n\t\t2) ADAPTER2
		\n\t\t3) CHRM
		\n\t\t4) RRNA	
\nOutput:
		\n\t1) F1: reads that pass polyA trimming
		\n\t2) F2: reads that pass chrM filtering
		\n\t3) F3: reads that pass rRNA filtering
		\n
		"
# cmd: ./filteringpe.sh phred64 8 s_1.fastq s_2.fastq output/s_pair

if [ $# -ne 5 ]
    then
#        echo -e $usage >&4
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
mkdir -p $outdir

# important: quality score type for far and bowtie. 
# hard code defined variable:
FAR_FORMAT="fastq-sanger"
BOWTIE_QUAL="--phred33-quals"
# for CMM data, which is phred 64, 
# FAR_FORMAT="fastq"
# BOWTIE_QUAL="--phred64-quals"

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

# function
fail () {
  echo "$1 step failed"
  exit 1
}

skip () {
  echo "$1 step skipped because already done."
}

section (){
  echo "[======$(date)======$1======]"
}

# quality score type:
getQual $QUALSCORE
echo "For far: $FAR_FORMAT"
echo "For bowtie: $BOWTIE_QUAL"
echo "Using $THREADS threads..."

############################################################################################################
# [ Quality and adaptor trimming ]
# Flexible Adapter Remover, version 2.0
# example /home/lishe/bin/far --adapters ~/genome/adaptor/pe/pe.fa --source CMM5_1.txt --source2 CMM5_2.txt --target CMM5_F1 --format fastq --cut-off 1 --min-overlap 10 --min-readlength 35 --phred-pre-trim 20 --max-uncalled 2 --adaptive-overlap yes
# section 1
# first filrter output file
#ADAPTER_OUTPUT_FILE="$V4SCRATCH/${LIBRARY}_F1_2.fastq.gz"
#if [[ ! -s $ADAPTER_OUTPUT_FILE ]]; then
#flexbar --adapters $ADAPTER \
#--source <( gunzip -c $INPUT1 ) \
#--source2 <( gunzip -c $INPUT2 ) \
#--target $V4SCRATCH/${LIBRARY}_F1 \
#--format $FAR_FORMAT \
#--threads $THREADS \
#--adapter-threshold 1 \
#--adapter-min-overlap 10 \
#--min-readlength 35 \
#--max-uncalled 5 \ || { rm -f $V4SCRATCH/${LIBRARY}_F1_{1,2}.fastq ;fail "Adaptor removing"; }
#RAN_ADAPTER=1
#gzip $V4SCRATCH/${LIBRARY}_F1_1*.fastq
#gzip $V4SCRATCH/${LIBRARY}_F1_2*.fastq
#
#else
#	skip "Adaptor removing"
#fi

# [Filter Quality Reads]
#second filter output file
#TRIM_OUTPUT_FILE="$V4SCRATCH/${LIBRARY}_F2_1.fastq.gz"
#if [[ $RAN_TRIM || ! -s $TRIM_OUTPUT_FILE ]]; then
#java -classpath trimmomatic-0.22.jar org.usadellab.trimmomatic.TrimmomaticPE -threads $THREADS -$TRIMMOMATIC_FORMAT $V4SCRATCH/${LIBRARY}_F1_1.fastq.gz $V4SCRATCH/${LIBRARY}_F1_2.fastq.gz $V4SCRATCH/${LIBRARY}_F2_1.fastq.gz $V4SCRATCH/${LIBRARY}_F2_1_single.fastq.gz $V4SCRATCH/${LIBRARY}_F2_2.fastq.gz $V4SCRATCH/${LIBRARY}_F2_2_single.fastq.gz LEADING:20 TRAILING:20 MINLEN:35 || { rm -f $V4SCRATCH/${LIBRARY}_F2_{1,2}.fastq ; fail "trimming";}
#RAN_TRIM=1
#rm $V4SCRATCH/${LIBRARY}_F1_1.fastq.gz
#rm $V4SCRATCH/${LIBRARY}_F1_2.fastq.gz
#rm $V4SCRATCH/${LIBRARY}_F1_1.fastq.lengthdist
#rm $V4SCRATCH/${LIBRARY}_F1_2.fastq.lengthdist
#else
#        skip "trimming..."
#fi
############################################################################################################


# [ PolyA/T trimming ]
prefix1="$outdir/${LIBRARY}_F1"

if [[ $RAN_POLYA || ! -s $POLYA_OUTPUT_FILE ]]; then
flexbar --adapters "$ADAPTER2" -r "$INPUT1" -p "$INPUT2" \
--target "$prefix1" \
--format "$FAR_FORMAT" \
--threads "$THREADS" &>"$prefix1.log" \
--max-uncalled 5 \
--min-read-length 35 \
--adapter-min-overlap 6 \
|| { rm -f "$prefix1"_{1,2}.fastq ; fail "PolyA removeing"; } 
RAN_POLYA=1
gzip "$prefix1"_1.fastq
gzip "$prefix1"_2.fastq
else
	skip "PolyA removeing"
fi

# [ ChrM filtering ]
# Indexes have to be generated beforehand.
prefix2="$outdir/${LIBRARY}_F2"
bowtie -q --un "$prefix2.fastq" --threads "$THREADS" "$CMCCHRM" -1 <(zcat ""$prefix1"_1.fastq.gz") -2 <(zcat ""$prefix1"_2.fastq.gz") &>"$prefix2".log
gzip "$prefix2"_1.fastq
gzip "$prefix2"_2.fastq
#rm "$outdir"/*_F1_*

# [ rRNA filtering ]
# Indexes have to be generated beforehand.
prefix3="$outdir/${LIBRARY}_F3"
bowtie -q --un "$prefix3.fastq" --threads "$THREADS" "$RRNA" -1 <(zcat ""$prefix2"_1.fastq.gz") -2 <(zcat ""$prefix2"_2.fastq.gz") &>"$prefix3".log
gzip "$prefix3"_1.fastq
gzip "$prefix3"_2.fastq
#rm "$outdir"/*_F1_*

# [ rRNA filtering ]
# bwa Version: 0.5.9-r16
# Indexes have to be generated beforehand.
#prefix3="$outdir/${LIBRARY}_F3"
# bwa parameters
#OPTIONS="-n 3 -o 2 -e 1 -k 2 -t "$THREADS""
#bwa aln "$OPTIONS" "$RRNA" "$prefix2"_1.fastq.gz > "$prefix3"_1.sai &>"$prefix3".log
#bwa aln "$OPTIONS" "$RRNA" "$prefix2"_2.fastq.gz > "$prefix3"_2.sai &>>"$prefix3".log
#bwa sampe -P "$RRNA" "$prefix3"_1.sai "$prefix3"_2.sai \
#  "$prefix2"_1.fastq.gz "$prefix2"_2.fastq.gz  > "$prefix3".sam &>>"$prefix3".log
#rm "$outdir"/*.sai
#rm "$outdir"/*.gz

# after bwa alignment, parse out unmapped reads and convert back to fastq file
#samtools view -S -f 0x04 "$prefix3".sam | java -Xmx2g -jar $SAMTOFASTQ INPUT=/dev/stdin VALIDATION_STRINGENCY=SILENT QUIET=true FASTQ="$prefix3"_1.fastq SECOND_END_FASTQ="$prefix3"_2.fastq

#gzip "$prefix3"_1.fastq
#gzip "$prefix3"_2.fastq
#rm "$prefix3".sam

# [ pairing sequence ]
# pair the paired end reads after bwa using Far
# example: PairedreadFinder -s1 CMM5_F2_1.fastq -s2 CMM5_F2_2.fastq -f fastq -t1 CMM5_1.paired -t2 CMM5_2.paired -is 2
# PairedreadFinder -s1 ${LIBRARY}_F2_1.fastq -s2 ${LIBRARY}_F2_2.fastq -f fastq -t1 ${LIBRARY}_1.paired -t2 ${LIBRARY}_2.paired -is 2
# [ program end ]
