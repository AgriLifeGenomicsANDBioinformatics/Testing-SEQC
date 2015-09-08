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
my $homologous_file= @ARGV[0];
my $homologous_name= @ARGV[0];
$homologous_name =~ s{.*/}{};      # removes path  
$homologous_name =~ s{\.[^.]+$}{}; # removes extension

# Variables
my %homologous=();  # Hash table with all the contigs in the file
my @matrix=();      # Distance matrix
my $sample_number;  # Number of contigs in the file

## Main
read_homologous();  # Read in the assembly
distance_matrix();  # Compute Kimura's distance
print_matrix();     # Print distance matrix

## Read in the homologous into hash table
sub read_homologous
{
    my $contig;
    open(my $homologous, $homologous_file) or die "Could not open file '$homologous_file' $!";
    while( my $line = <$homologous>)
    {
        chomp($line);
        if( $line =~ />/)
        {
            $contig=substr($line,1); # Get rid of leading ">" character
            $homologous{$contig}="";
        }
        else
        {
            $homologous{$contig} .= $line;
        }
    }
    # From strings to arrays
    foreach my $key (keys %homologous)
    {
        my @seq=split //,$homologous{$key};
        $homologous{$key}=[@seq]; # Convert to an array of nucleotides
    }
    $sample_number = keys %homologous;
}

## Find distance
sub distance_matrix
{
    my $i=0;
    foreach my $x (keys %homologous)
    {
        my $j=0;
        foreach my $y (keys %homologous)
        {           
            my $dist=pairwise_distance(\@{$homologous{$x}},\@{$homologous{$y}});
            $matrix[$i][$j]=$dist;
            $j+=1;
        }
        $i+=1;
    }
}

## Compute pairwise distance
sub pairwise_distance
{
    my $seq1_ref=shift;
    my $seq2_ref=shift;
    my @seq1=@{$seq1_ref};
    my @seq2=@{$seq2_ref};
    my $dist=0;
    foreach (my $i = 0; $i < $#seq1; $i++) 
    {
        if( @seq1[$i] ne @seq2[$i]){$dist+=1}
    }
    return $dist;
}

## Sub to print output
sub print_matrix
{
    for(my $row = 0; $row < $sample_number; $row++) 
    {
        for(my $col = 0; $col < $sample_number; $col++) 
        {
            print "$matrix[$row][$col]\t"
        }
    print "\n";
    }
}
