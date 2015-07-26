#!/usr/bin/env bash
rm -f contigs.log
rm -rf out

../multipleAlignment.sh -d out -s RNA -- contigs.fa
