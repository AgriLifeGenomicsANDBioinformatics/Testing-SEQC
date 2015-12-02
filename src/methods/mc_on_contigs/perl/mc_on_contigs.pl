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
use DateTime;

# 3rd party dependancies
use Algorithm::Combinatorics qw(combinations variations_with_repetition);   # Combinatorics (used to determine variations with rep)
#use Math::Matrix;                       # Matrix operations
#use PDL;                                # Perl Data Language Libraries
#use PDL::Matrix;                        # Environment for matrices
#use PDL::MatrixOps;                     # Operations for matrices

# Read arguments
my $scriptname = $0;            # Get script name
my $fasta_file = @ARGV[0];      # Get target FASTA file name
my $kmer_size= @ARGV[1];        # Get user k-mer size

# Variables
my $Niter=5;                    # Power to which P is raised, i.e. P^Niter
my $dim=1;                      # Dimension P (based on k-mer size)
my @markov_matrix=();           # 3D array [assembly][row][column]
my @steady_state=();            # 2D array [assembly][limiting prob]
my $matrix_object=();           # Object from PDL::Matrix containing P
my $transpose_object=();        # Object from PDL::Matrix containing t(P)
my $eigen_vectors=();           # Object from PDL::Matrix containing eigen vectors of t(P)
my $eigen_values=();            # Object from PDL::Matrix containing eigen values of t(P)
my $phi_object=();              # Object from PDL::Matrix containing phi
my $mth_object=();              # Object from PDL::Matrix containing P^m

# Time stamps
my $st_time=0;                  # Start time
my $end_time=0;                 # End time
my $current_time=0;             # Current time
my $elapsed_time=0;             # Time elapsed

# Hashes
my %fasta_hash=();              # Hash containing sequence info of each sample
my %transition_hash=();         # Hash containing duplets combinations
my %sample_hash=();             # Assign a numeric ID to each Assembly
my %inner_product_hash=();      # Inner product between SSDs.

######################################### Main ######################################

# Read in fasta file
$st_time = DateTime->now();
print STDERR "${st_time}: Working on ${fasta_file} ...\n";
read_fasta();
#print_fasta();

# Initialize Markov matrices
initialize();
fill_markov_matrix();
print_markov_matrix();
print STDERR "${st_time}: Transition matrix for ${fasta_file} done.\n";


######################################################################################

########################################### Subs ######################################

## Fill the markov_matrix
sub fill_markov_matrix
{
    foreach my $contig (keys %fasta_hash)
    {
        for(my $i=0;$i<=(scalar @{$fasta_hash{$contig}})-2*$kmer_size;$i++)
        {
            # Get nucleotides of the iteration
            my $seq_1=@{$fasta_hash{$contig}}[$i];
            my $seq_2=@{$fasta_hash{$contig}}[$i+$kmer_size];
            for(my $j=1;$j<$kmer_size;$j++)
            {
                $seq_1=$seq_1.@{$fasta_hash{$contig}}[$i+$j];
                $seq_2=$seq_2.@{$fasta_hash{$contig}}[$i+$kmer_size+$j];
            }
            # Get codon index form markov_matrix
            my $row=$transition_hash{$seq_1};
            my $col=$transition_hash{$seq_2};
            # Fill markov_matrix
            $markov_matrix[$row][$col]+=1; 
        }
    }
    # Scale matrix
    my $sum;
    for(my $i=0;$i<=$dim;$i++)
    {
        $sum=0;
        # Counts per row
        for(my $j=0;$j<=$dim;$j++)
        {
            $sum+=$markov_matrix[$i][$j];
        }
        # Normalize each row
        if($sum!=0)
        {
            for(my $j=0;$j<=$dim;$j++)
            {
                $markov_matrix[$i][$j]/=$sum;
            }
        }
    }
}

## Initialize Markov matrix
sub initialize
{
    # Nucleotides taken into consideration
    my @nucleotides=('A','C','T','G');
    for(my $i=1;$i<=$kmer_size;$i++)
    {
        $dim*=(scalar @nucleotides);
    }
    # Because we start with dim=0 in the loops
    $dim-=1;
    # Get all possible combinations of kmer_size nucleotides
    my @permutations=variations_with_repetition(\@nucleotides,$kmer_size);
    # Codify numerically each possible permutation
    my $i=0;
    foreach my $combination (@permutations)
    {   
        my $length=$kmer_size-1;
        my $sequence = join('', @{$combination}[0..$length]);
        $transition_hash{$sequence}=$i;
        $i++;
    } 
    # Initialize markov_matrix
    for(my $i=0;$i<=$dim;$i++)
    {
        for(my $j=0;$j<=$dim;$j++)
        {
            $markov_matrix[$i][$j]=0;
        }
    }
}

## Read in fasta file
sub read_fasta
{
    my $contig;
    open(my $FH, $fasta_file) or die "Could not open file '$fasta_file' $!";
    while( my $line = <$FH>)
    {   
        chomp($line);
        if( $line =~ />/)
        {   
            $contig=substr($line,1); # Get rid of leading ">" character
            $fasta_hash{$contig}="";
        }   
        else
        {   
            my @array = split //, $line;
            $fasta_hash{$contig} = [@array];
        }   
    }   
}

## Print fasta
sub print_fasta
{
    # Print output
    foreach my $key (sort keys %fasta_hash)
    {
        my @contig=@{$fasta_hash{$key}};
        print ">$key\n";
        foreach my $nuc (@contig)
        {
            print "$nuc";
        }
        print "\n";
    }
}

## Print markov_matrix
sub print_markov_matrix
{
    # Reverse hash
    my %reverse_hash = reverse %transition_hash;
    for(my $j=0;$j<=$dim;$j++)
    {
        print "\t";
        my $key = $reverse_hash{$j};
        print "$key";
    }
    print "\n";
    for(my $i=0;$i<=$dim;$i++)
    {   
        my $key = $reverse_hash{$i};
        print "$key\t";
        for(my $j=0;$j<=$dim;$j++)
        {
            printf "%.3f\t", $markov_matrix[$i][$j];
        }
        print "\n";
    }
}

###########################################################################################
