
<snippet>
  <content><![CDATA[
# ${1:Testing SEQC}

TODO: Write a project description

## Installation

1. Every folder (./script_name) will contain the following files and folder:
  a. sript_name.sh: bash script
  b. ./main
    i. main.sh: bash script to try the command with toy example.
    ii. Files required for the toy example.
2. The folder ./fastaFiles contains reference genomes, chrM and rRNA fasta files. This folder should be added to the environment variable $BOWTIE_INDEXES. This can be done by adding the following line to the .bashrc file:
      export BOWTIE_INDEXES="$HOME/code/linux/bin/bowtiepkg/src/refGenomes"  
Indexes are already generated, i.e. there is no need to run bowtie index.
3. It is required to have:
  a. R
  b. perl
  c. python (not v3)
3. If the machine running the code is Machintosh install coreutils (sudo port install coreutils) as well as:
  a. gzip
  b. grep
  c. getopt
4. The following packages should be available in the path variable in the machine running the code:
  a. bowtie
  b. bowtie2
  b. flexbar
  c. samtools
  d. tophat2
  e. cutadapt

## Usage

TODO: Write usage instructions

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

TODO: Write history

## Credits

TODO: Write credits

## License

TODO: Write license
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>
