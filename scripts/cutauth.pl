#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter seq4 records and remove trailing author comment, ".", (End)" etc.
#:# Usage:
#:#   perl cutauth.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+\t}) { # assume seq4 format
        s/\s+\Z//;
        my ($aseqno, $callcode, @parms) = split(/\t/);
        my $parmi = $parms[$iparm];

        $parmi =~ s{\[[A-Za-z][^\<\>\=\]]+\]}        {}; # remove "[From _G. F.]"
        $parmi =~ s{\. +\- \_[A-Z]\w+\.? [A-Z].*}    {}; # remove ". - _G. F."
        $parmi =~ s{\([Ee]nd\)\. *\Z}                {}; # remove trailing "(End)." 
        $parmi =~ s{[^\.]\. *\Z}                     {}; # remove trailing "." 

        $parms[$iparm] = $parmi;
        print join("\t", $aseqno, $callcode, @parms) . "\n";
    } else { # no seq4
        print;
    }
} # while
__DATA__
# test data
A005738	lsm	0	a(n) = Sum_{k=0..n-1} binomial(n,k) * A005616(k). [From Kodandapani and Seth] - _Sean A. Irvine_, Jul 21 2016
A005739	lsm	0	a(n) = A005616(n) + A005738(n) [From Kodandapani and Seth]. - _Sean A. Irvine_, Jul 21 2016
