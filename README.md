Project description
-------------------

TODO: Write a project description

Installation
------------------

1. Clone the repository:

        git clone git@github.com:AgriLifeGenomicsANDBioinformatics/Testing-SEQC.git

2. Add the bin folder in the repository to your path variable by adding the following line to the `.bashrc` file:

        export PATH="path/to/bin:$PATH"

3. The folder `./fastaFiles/` contains reference genomes, chrM and rRNA fasta files. This folder should be added to the environment variable `$BOWTIE_INDEXES`. This can be done by adding the following line to the `~/.bashrc` file:

        export BOWTIE_INDEXES="path/to/fastaFiles"

    Indexes are already generated, i.e. there is no need to run bowtie index.

4. It is required to have:
  1. R (v3.X.X)
  2. perl (v5)
  3. python (v2)
  4. java (v1.7.X)

5. If the machine running the code is Machintosh install coreutils (sudo port install coreutils) as well as:
  1. gzip
  2. grep
  3. getopt
  4. mysql
  5. openssl
  6. readline
  7. boost
  8. zlib
  9. gcc4.9

6. The following packages should be available in the path variable in the machine running the code:
  1. bowtie (1.1.0 recommended)
  2. bowtie2 (2.2.3 recommended)
  3. flexbar (2.5 recommended)
  4. samtools (1.2 recommended)
  5. tophat2 (v2.0.14 recommended)
  6. cutadapt (1.8.1 recommended)
  7. trinity (v2.0.6 recommended)

Usage
-----------------

1. Every folder (`./script_name`) will contain the following files and folder:
  1. `./sript_name.sh`: bash script
  2. `./main/`
    * `./main.sh`: bash script to try the command with toy example.
    * Files required for the toy example.

####filteringPE.sh

          filteringPE.sh QUAL THREADS INPUTPAIR1 INPUTPAIR2

####trinityPE.sh

          trinityPE.sh [OPTIONS] -- read_r1.fastq.gz read_r2.fastq.gz

Contributing
----------------

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

History
---------------

TODO: Write history

Credits
---------------

TODO: Write credits

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
