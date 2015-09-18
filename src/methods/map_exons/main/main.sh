#!/usr/bin/env bash
rm -rf out

../map_exons.sh -t 4 -d out -- transcript1.fa exons.fa
