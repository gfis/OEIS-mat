#!perl

# Extract binomial coefficient sequences
# @(#) $Id$
# 2021-06-03, Georg Fischer
#
#---------------------------------
use strict;
use integer;
use warnings;

while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my $callcode = "holos";
    my $aseqno = substr($line, 3, 7);
    if ($line =~ m{Binomial coefficients? *\:* *\w+\(([^\)]+)(.*)}i) { 
        my ($rec, $rest) = ($1, $2);
        my $nok = 0;
        if ($rest =~ m{such|that}) {
            $nok = 1;
        }
        $rest =~ s{ = .*}{};
        if (length($rest) > 2) {
            $nok = 2;
        }
        $rec =~ s{ }{}g;
        $rec =~ s{(\d|\))([a-zA-Z]|\()}{$1\*$2}g;
        $rec =~ s{(n)(\()}{$1\*$2}g;
        $rec = "binomial($rec)";
        if ($nok == 0) {
            print        join("\t", $aseqno, "binomin0", 0, $rec, "1", 0, 0, "$rec") . "\n"; 
        } else {
            print STDERR join("\t", $aseqno, "rest$nok", 0, $rec, "N") . "\n"; 
        }
    }
} # while <>
__DATA__
#N A000332 Binomial coefficient binomial(n,4) = n*(n-1)*(n-2)*(n-3)/24.
#N A000389 Binomial coefficients C(n,5).
#N A001449 Binomial coefficients binomial(5n,n).
#N A002054 Binomial coefficient C(2n+1, n-1).
#N A002299 Binomial coefficients C(2*n+5,5).
#N A002694 Binomial coefficients C(2n, n-2).
#N A002696 Binomial coefficients C(2n,n-3)
