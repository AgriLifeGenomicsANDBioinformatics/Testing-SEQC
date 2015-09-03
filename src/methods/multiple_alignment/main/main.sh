#!/usr/bin/env bash
rm -f contigs.log
rm -rf out

../multiple_alignment.sh -d out -s RNA -- contigs.fa
