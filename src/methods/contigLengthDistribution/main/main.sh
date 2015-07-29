#!/usr/bin/env bash
rm -f contigs.log
rm -rf out

../contigLengthDistribution.sh -d out -- contigs.fa
