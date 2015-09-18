#!/usr/bin/env perl
# ------------------------------------------------------------------------------
##The MIT License (MIT)
##
##Copyright (c) 2015 Jordi Abante
##
##Permission is hereby granted, free of charge, to any person obtaining a copy
##of this software and associated documentation files (the "Software"), to deal
##in the Software without restriction, including without limitation the rights
##to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
##copies of the Software, and to permit persons to whom the Software is
##furnished to do so, subject to the following conditions:
##
##The above copyright notice and this permission notice shall be included in all
##copies or substantial portions of the Software.
##
##THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
##IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
##FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
##AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
##LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
##OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
##SOFTWARE.
# ------------------------------------------------------------------------------

# Libraries
use strict;

# Read arguments
my $scriptname = $0;
my $transcript_file= @ARGV[0];
my $transcript_name= @ARGV[0];
$transcript_name =~ s{.*/}{};      # removes path  
$transcript_name =~ s{\.[^.]+$}{}; # removes extension
my $output_prefix = @ARGV[1];

# Variables
my %hash=();
my %transcript=();

## Main
read_transcript();  # Read in the assembly
filter_data();      # Select a contig per each exon combination
generate_files();   # Generate a file for each existant combination with one contig

## Read in the transcript into hash table
sub read_transcript{
    my $contig;
    open(my $TRANSCRIPT, $transcript_file) or die "Could not open file '$transcript_file' $!";
    while( my $line = <$TRANSCRIPT>)
    {
        chomp($line);
        if( $line =~ />/)
        {
            $contig=substr($line,1); # Get rid of leading ">" character
            $transcript{$contig}="";
        }
        else
        {
            $transcript{$contig} .= $line;
        }
    }
}
## Sub to filter stdin
sub filter_data{
    # Read in trancript file
    foreach my $line (<STDIN>) {
        # Get info from line
        chomp($line);
        my ($contig,$exons,$evalues)=split('\t',$line);
        my @evalues=split(',',$evalues);
        # Compute multiple evalues (Bonferroni correction)
        my $evalue_bonferroni=1;
        foreach(@evalues){$evalue_bonferroni*=$_};
        # Hash table   
        if(exists($hash{$exons}))
        {
            # Compare evalues
            if($hash{$exons}[1]>$evalue_bonferroni)
            {
                $hash{$exons}=[$contig,$evalue_bonferroni];
            }
        }
        else
        {
            $hash{$exons}=[$contig,$evalue_bonferroni];
        }
    }
}

## Sub to generate a file for each key in hash table
sub generate_files{  
    foreach my $key (keys %hash)
    {
        # Get exon combinations
        my $contig=$hash{$key}[0];
        # Look for contig in transcriptome
        if(exists($transcript{$contig}))
        {
            my $filename = join('',$output_prefix,$key,".fa");
            open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
            print $fh ">${transcript_name}_${contig}\n$transcript{$contig}\n";
            close $fh;
        }
    }
}

## Sub to print
sub print_out{
    # Print output
    foreach my $key (keys %hash)
    {
        my $contig=$hash{$key}[0];
        my $evalue=$hash{$key}[1];
        print "$key\t$contig\n";
    }
}
