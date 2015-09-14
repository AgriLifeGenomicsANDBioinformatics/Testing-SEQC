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
$homologous_name =~ s{.*/}{};       # removes path  
$homologous_name =~ s{\.[^.]+$}{};  # removes extension
my $outdir= @ARGV[1];

# Variables
my %homologous=();  # Hash table with all the contigs in the file
my @matrix=();      # Distance matrix
my $sample_number;  # Number of contigs in the file

## Main
read_homologous();  # Read in the assembly
distance_matrix();  # Compute Kimura's distance
save_matrix();      # Write matrix in output file
#print_matrix();     # Print distance matrix

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
    foreach my $x (sort keys %homologous)
    {
        my $j=0;
        foreach my $y (sort keys %homologous)
        {           
            my $dist=0;
            if($x ne $y)
            {
                $dist=pairwise_distance(\@{$homologous{$x}},\@{$homologous{$y}});
            } 
            elsif($i>$j)
            {
                $dist=$matrix[$j][$i];
            }
            $matrix[$i][$j]=$dist;
            $j+=1;
        }
        $i+=1;
    }
}

## Compute pairwise distance
sub pairwise_distance
{
    # Input arrays
    my $seq1_ref=shift;
    my $seq2_ref=shift;
    my @seq1=@{$seq1_ref};
    my @seq2=@{$seq2_ref};
    # Distance variables
    my $p=0;        # Proportion of sites that show transitional differences, i.e. A<=>G or C<=>T
    my $q=0;        # Proportion of sites that show transversional differences, i.e. [AG]<=>[CT]
    my $dist=0;     # Kimura's two-parameter distance
    # Compute p and q
    foreach (my $i = 0; $i < ($#seq1+1); $i++) 
    {
        if((@seq1[$i] =~ /[AG]/) && (@seq2[$i] =~ /[AG]/))
        {
            if(@seq1[$i] ne @seq2[$i])
            {
                $p++;
            }
        } 
        elsif ((@seq1[$i] =~ /[CT]/) && (@seq2[$i] =~ /[CT]/))
        {
            if(@seq1[$i] ne @seq2[$i])
            {
                $p++;
            }
        } 
        elsif ((@seq1[$i] =~ /-/) or (@seq2[$i] =~ /-/))
        {
            # Deal with indels
        }
        else
        {
            $q++;
        }
    }
    $p/=($#seq1+1);
    $q/=($#seq1+1);
    # Compute distance
    my $arg1=1-2*$p-$q;
    my $arg2=1-2*$q;
    # If one of the arguments is zero log=Inf
    if($arg1 >0 and $arg2 >0)
    {
        $dist=-0.5*log($arg1)-0.25*log($arg2);
    } 
    else
    {
        $dist="inf";
    }
    # Return value
    return $dist;
}

## Generate output file
sub save_matrix
{
    # Array with contig IDs
    my @ids=();
    # Op-en output file
    my $filename = join('',$outdir,"/",$homologous_name,"_dist.txt");
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    # Print first row just IDs
    print $fh "\t";
    foreach my $key (sort keys %homologous)
    {   
        push @ids,$key;
        print $fh "$key\t";
    }
    print $fh "\n";
    # Print ID and values for each row
    for(my $row = 0; $row < $sample_number; $row++) 
    {
        print $fh "$ids[$row]\t";
        for(my $col = 0; $col < $sample_number; $col++) 
        {
            print $fh "$matrix[$row][$col]\t";
        }
    print $fh "\n";
    }
    # Close FH
    close $fh;
}

## Sub to print output to STDERR
sub print_matrix
{  
    my @ids=();
    print STDERR "\t";
    foreach my $key (sort keys %homologous)
    {   
        push @ids,$key;
        print STDERR "$key\t";
    }
    print STDERR "\n";
    for(my $row = 0; $row < $sample_number; $row++) 
    {
        print STDERR "$ids[$row]\t";
        for(my $col = 0; $col < $sample_number; $col++) 
        {
            
            print STDERR "$matrix[$row][$col]\t"
        }
    print "\n";
    }
}

