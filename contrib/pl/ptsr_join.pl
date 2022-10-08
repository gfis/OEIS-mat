#!perl

# Join pairs of A-numbers in the result of ptsearch.pl
# @(#) $Id$
# 2022-10-02, Georg Fischer
#
#:# Usage:
#:#   perl ptsr_join.pl ptsr.tmp | tee output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

my $state = 0;
my ($aseqno, $rseqno, $callcode, $offset, $data);
while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    if (0) {
    } elsif ($line =~ m{\A\=\=}) {
        $state = 1;
    } elsif ($line =~ m{\t\-\-}) {
        ($aseqno, $callcode, $offset, $data) = split(/\t/, $line);
        $state = 2;
    } elsif ($state == 2 && ($line =~ m{\t\.\.})) {
        my @rest;
        ($rseqno, @rest) = split(/\t/, $line);
        print join("\t", $rseqno, 'partran', $offset, $aseqno, $data) . "\n";
    }
} # while <>
__DATA__
========
A317710 --a1    0       1,2,1,3,4,1,4,10,6,1,5,20,21,8,1,6,35,56,36,10,1,7,56,126,120,55,12,1,8,84,252,330,220,78,14,1
A078812 ..a1    0       1,2,1,3,4,1,4,10,6,1,5,20,21,8,1,6,35,56,36,10,1,7,56,126,120,55
========
A317742 --a1    0       1,0,1,1,0,1,0,2,0,1,1,0,3,0,1,0,3,0,4,0,1,1,0,6,0,5,0,1,0,4,0,10,0,6,0,1
A168561 ..a1    0       1,0,1,1,0,1,0,2,0,1,1,0,3,0,1,0,3,0,4,0,1,1,0,6,0,5,0,1,0,4,0,10
