#!/usr/bin/env bash

kallistoQuant.sh -d out1 transcripts.idx reads_1.fastq.gz reads_2.fastq.gz
kallistoQuant.sh -d out2 -b 200 -p "_" transcripts.idx reads_1.fastq.gz reads_2.fastq.gz
kallistoQuant.sh -d out3 -s 30 -b 200 -p "_" transcripts.idx reads_1.fastq.gz reads_2.fastq.gz
kallistoQuant.sh -d out4 -s 30 -b 200 -p "_1" --singleEnd transcripts.idx reads_1.fastq.gz
