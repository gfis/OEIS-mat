#!perl

# Preprocess "Number of earlier terms ..." 
# @(#) $Id$
# 2026-03-11, V9.1: Pnnnnnn = DirectPredicate
#:# Usage:
#:#   perl earlier.pl in > out
#--------------------------------------------------------
use strict;
use integer;
use warnings;

while (<>) {
    s/ \= /\=/g; 
    s/ *for n *\>\=? *\d+\, */ /i; 
    s/of the sequence//; 
    s/(such that|(which|that)( are)?) */ /; 
    s/((is )?(the )?number of earlier terms */NET /; 
    # A123456\ta(0)=1. a(n)=NET ,
    s/[\.\;//g;
    my $line = $_;
    #               1  1    2  2
    $line =~ s/\ta\((\d)\)\=(\d) *a\(n\)NET */\tmultia\t$1\t\"$2\"\t\(self, n\) \-\> CNT\(\t/;
    print $line;
}