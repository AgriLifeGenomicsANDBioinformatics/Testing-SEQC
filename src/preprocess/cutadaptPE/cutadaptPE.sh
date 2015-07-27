#!/usr/bin/env bash

# Discarding_Adapters.sh
# MAC_Xcode
#
# Created by Noushin Ghaffari on 5/5/15.
# Copyright 2015 __MyCompanyName__. All rights reserved.

set -e
shopt -s extglob # To work with regex

abspath_script="$(readlink -f -e "$0")"
script_absdir="$(dirname "$abspath_script")"
script_name="$(basename "$0")"

usage="
Description:
\n\tThe script is aimed to clean paired-end reads by adaptor.\n
\nUsage:
\n\t"$script_name" INPUT_DIR OUTPUT_DIR FILE_PREFIX\n
\nE.g.
\n\tcutadaptPE.sh ./ ./output read\n
"

if [ $# -ne 3 ]
    then
        echo $usage >&2
        exit 1
fi


#Testing the cutadpat on max, using 1 paired data from AGR (SEQC_ILM_AGR_A_1_L01_ATCACG_AC0C1TACXX)

#Input_Directory="/home/data/SEQC/ILM_AGR"
Input_Directory=$1
Working_Directory=.
Output_Directory=$2
fileIdentifier=$3
#Output_Directory="/home/noushin.ghaffari/SEQC/Adapter_Discaring"

FWD="-a AGATCGGAAGAGCACACGTC -a GACGTGTGCTCTTCCGATCT -a AGATCGGAAGAGCGGTTCAG -a CTGAACCGCTCTTCCGATCT -a GATCGGAAGAGCGGTTCAGCAGGAATGCCGAG"
REV="-a AGATCGGAAGAGCGTCGTGT -a ACACGACGCTCTTCCGATCT -a ACACTCTTTCCCTACACGACGCTCTTCCGATCT"

read1="${fileIdentifier}_R1"
read2="${fileIdentifier}_R2"

exten=".fastq.gz"

trim="_Trimmed"

Output_Adapter_Discard="${fileIdentifier}Outputs_Adapter_Discard.txt"

Cutadapt_Outputs="${fileIdentifier}Cutadapt_Outputs.txt"

date > ${Output_Adapter_Discard}

#cp $Input_Directory/$read1$exten $Output_Directory
#cp $Input_Directory/$read2$exten $Output_Directory

echo $Input_Directory/$read1$exten >> ${Output_Adapter_Discard}
zcat $Input_Directory/$read1$exten | wc -l  >> ${Output_Adapter_Discard}
echo $Input_Directory/$read2$exten >> ${Output_Adapter_Discard}
zcat $Input_Directory/$read2$exten | wc -l  >> ${Output_Adapter_Discard}


cutadapt $FWD --discard-trimmed --output=${fileIdentifier}tmp.1.fastq     --paired-output=${fileIdentifier}tmp.2.fastq     $Input_Directory/$read1$exten $Input_Directory/$read2$exten > $Cutadapt_Outputs
cutadapt $REV --discard-trimmed --output=$Output_Directory/$read2$trim.2$exten --paired-output=$Output_Directory/$read1$trim.1$exten ${fileIdentifier}tmp.2.fastq   ${fileIdentifier}tmp.1.fastq >> $Cutadapt_Outputs
rm ${fileIdentifier}tmp.1.fastq ${fileIdentifier}tmp.2.fastq


#zcat $Input_Directory/$read1$exten | wc -l  >> $Output_Directory/Outputs_Adapter_Discard.txt
#zcat $Input_Directory/$read2$exten | wc -l  >> $Output_Directory/Outputs_Adapter_Discard.txt

date >> ${Output_Adapter_Discard}

echo $Output_Directory/$read1$trim.1$exten >> ${Output_Adapter_Discard}
zcat $Output_Directory/$read1$trim.1$exten | wc -l  >> ${Output_Adapter_Discard}
echo $Output_Directory/$read1$trim.2$exten >> ${Output_Adapter_Discard}
zcat $Output_Directory/$read2$trim.2$exten | wc -l  >> ${Output_Adapter_Discard}


date >> ${Output_Adapter_Discard}
