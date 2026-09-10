#!perl

# Preprocess sequences with names "Number of earlier terms ..." of Leroy Quet
# @(#) $Id$
# 2026-09-10, Georg Fischer; *CH=50
#:# Usage:
#:#   perl earlier.pl in > out
#--------------------------------------------------------
use strict;
use integer;
use warnings;

while (<>) {
    next if !m{^A};
    s/\'//g;
    s/ \= /\=/g; 
    s/ *for n *\>\=? *\d+\, */ /i; 
    s/of the sequence//; 
    s/(such that|(which|that)( are)?) */ /; 
    s/(is )?(the )?number of earlier terms */NET /; 
    s/[\.\;]//g;
    
    my $line = $_;
    #A127463	a(0)=1 a(n)=NET a(k), 0<=k<=n-1,  (k+a(k)) is coprime to n
    #               1  1    2  2
    $line =~ s{\ta\((\d)\)\=(\d) *a\(n\)[ \=]NET *}
              {\tmultia\t$1\t\"$2\"\t\(self, n\) \-\> CNT\($1\, n \- 1\, k \-\> Predicates..is(self.a(k)))\t};
    print "$line";
}