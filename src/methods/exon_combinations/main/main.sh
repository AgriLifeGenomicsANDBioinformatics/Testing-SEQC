#!/usr/bin/env bash
rm -rf out

../map_exons.sh -d out -- transcript1.fa exons.fa
