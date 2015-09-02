#!/usr/bin/env bash
rm -rf out

../collapse_homologous.sh -d out -- exon_hits
