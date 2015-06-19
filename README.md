Project description
-------------------

TODO: Write a project description

Installation
------------------

1. Every folder (./script_name) will contain the following files and folder:
  1. sript_name.sh: bash script
  2. ./main
    * main.sh: bash script to try the command with toy example.
    * Files required for the toy example.

2. The folder ./fastaFiles contains reference genomes, chrM and rRNA fasta files. This folder should be added to the environment variable $BOWTIE_INDEXES. This can be done by adding the following line to the .bashrc file:

            export BOWTIE_INDEXES="$HOME/code/linux/bin/bowtiepkg/src/refGenomes"

    Indexes are already generated, i.e. there is no need to run bowtie index.

3. It is required to have:
  1. R
  2. perl
  3. python (not v3)

3. If the machine running the code is Machintosh install coreutils (sudo port install coreutils) as well as:
  1. gzip
  2. grep
  3. getopt

4. The following packages should be available in the path variable in the machine running the code:
  1. bowtie
  2. bowtie2
  3. flexbar
  4. samtools
  5. tophat2
  6. cutadapt

Usage
-----------------

###filtering.sh

          filtering.sh QUALSCORE THREADS INPUTPAIR1 INPUTPAIR2 LIBRARY

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

TODO: Write license

![Minion](http://octodex.github.com/images/minion.png)
