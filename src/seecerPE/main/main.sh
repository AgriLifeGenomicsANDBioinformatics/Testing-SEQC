#!/usr/bin/env bash

seecerPE.sh -k 20 -- reads/read1_r1.fastq reads/read1_r2.fastq seecerPEOut &
seecerPE.sh -k 20 -- reads/read2_r1.fastq.gz reads/read2_r2.fastq.gz seecerPEOut

gunzip ./reads/read1*
