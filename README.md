Installation
------------------

1. Clone the repository:

        git clone git@github.com:AgriLifeGenomicsANDBioinformatics/Testing-SEQC.git

2. Add the bin folder in the repository to your path variable by adding the following line to the `.bashrc` file:

        export PATH="path/to/bin:$PATH"

3. The folder `./fastaFiles/` contains reference genomes, chrM and rRNA fasta files. This folder should be added to the environment variable `$BOWTIE_INDEXES`. This can be done by adding the following line to the `~/.bashrc` file:

        export BOWTIE_INDEXES="path/to/fastaFiles"

    Indexes are already generated, i.e. there is no need to run `bowtie index`.

Dependancies
------------------
1. It is required to have:
  1. R (v3.X.X)
  2. perl (v5)
  3. python (v2)
  4. java (v1.7.X)

2. If the machine running the code is Machintosh install coreutils (sudo port install coreutils) as well as: gzip, grep, getopt, mysql, openssl, readline, boost, zlib.

3. The following packages should be available in the path variable in the machine running the code:
  1. cutadaptPE.sh
    1. cutadapt
  2. filteringPE.sh
    1. bowtie
    2. flexbar
    3. samtools
  3. seecerPE.sh
    1. SEECER
    2. jellyfish
    3. seqan
  4. rsemEvalPE.sh
    1. rsem-eval-calculate-score
    2. rsem-eval-estimate-transcript-length-distribution
    3. bowtie
  5. refEvalPE.sh
    1. blat
    2. ref-eval
    3. rsem-calculate-expression
    4. rsem-prepare-reference
    5. bowtie2
  6. cegma.sh
    1. CEGMA
    2. geneid
    3. genewise
  7. tophat2PE.sh
    1. bowtie2
    2. tophat2

Usage
-----------------

1. Every folder (`script_name`) will contain the following files and directories:
  1. `sript_name.sh`: bash script
  2. `main/`
    * `main.sh`: bash script to try the command with toy example.
    * Files required for the toy example.
  3. `pbs/`
    * `script_name.pbs`: pbs script to run the command on blacklight.

####cutadaptPE.sh

          cutadaptPE.sh INPUT_DIR OUTPUT_DIR  READS_PREFIX

####filteringPE.sh

          filteringPE.sh QUAL THREADS INPUTPAIR1 INPUTPAIR2 OUTPUT_DIR

####seecerPE.sh

          seecerPE.sh [OPTIONS] -- INPUTPAIR1 INPUTPAIR2 OUTPUT_DIR

####rsemEvalPE.sh

          rsemEvalPE.sh [OPTIONS] -- INPUTPAIR1 INPUTPAIR2  ASSEMBLY OUTPUT_DIR

####refEvalPE.sh

          refEvalPE.sh [OPTIONS] -- ASSEMBLY REFERENCE INPUTPAIR1 INPUTPAIR2  OUTPUT_DIR

####cegma.sh

          cegma.sh [OPTIONS] -- ASSEMBLY CORE_GENES OUTPUT_DIR

####tophat2PE.sh

          tophat2PE.sh [OPTIONS] -- ASSEMBLY/REFERENCE INPUTPAIR1 INPUTPAIR2 OUTPUT_DIR

License
---------------

The MIT License (MIT)

Copyright (c) 2015 [fullname]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

![Minion](http://octodex.github.com/images/minion.png)
