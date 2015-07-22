#!/usr/bin/env bash

rm -rf filteringPE*
set -x

filteringPE.sh i1.8 2 reads/SEQC_ILM_AGR_A_1_L01_ATCACG_AC0C1TACXX_R1.fastq.gz \
  reads/SEQC_ILM_AGR_A_1_L01_ATCACG_AC0C1TACXX_R2.fastq.gz \
  filteringPEOut
filteringPE.sh i1.8 2 reads/SEQC_ILM_AGR_A_1_L01_ATCACG_BD0J2JACXX_R1.fastq.gz \
  reads/SEQC_ILM_AGR_A_1_L01_ATCACG_BD0J2JACXX_R2.fastq.gz \
  filteringPEOut
