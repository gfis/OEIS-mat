#!perl

# @(#) $Id$
# 2024-06-28, Georg Fischer
#
#:# Filter records and remove trailing author comment, ".", (End)" etc.
#:# Usage:
#:#   perl cutauth.pl infile.seq4 > outfile.seq4
#--------------------------------------------------------
use strict;
use integer;
use warnings;

my $iparm = 1; # operate on this parameter
#while (<DATA>) {
while (<>) {
    if (m{\AA\d+}) { # starts with A-number
        s/\s+\Z//;
        my $parm = $_;

        $parm =~ s{\.[^\,]+\, [A-Z][a-z]{2} \d\d \d{4}.*} {};
        $parm =~ s{\[From [A-Za-z\_][^\]]+\]}             {}i;  # remove "[From _G. F.]"
        $parm =~ s{\. +\- +_?[A-Z]\w*\.? [A-Zvd].*}       {};   # remove ". - _G. F."
        $parm =~ s{\- _[A-Z][a-z]*\.* [A-Z][a-z]*\.*[^\,]*\, \w{3} \d{2} \d{4}.*} {};
        $parm =~ s{\(End\)\.? *\Z}                        {}i;  # remove trailing "(End)."
        $parm =~ s{\((based on|corrected).*}              {};   # remove trailing "(based on", "(corrected"
        $parm =~ s{\,? *where.*}                          {};   # remove " where ..."
        $parm =~ s{\. *\Z}                                {};   # remove trailing "."

        print "$parm\n";
    } else { # no seq4
        # print;
    }
} # while
__DATA__
# test data
A005738	lsm	0	a(n) = Sum_{k=0..n-1} binomial(n,k) * A005616(k). [From Kodandapani and Seth] - _Sean A. Irvine_, Jul 21 2016
A005739	lsm	0	a(n) = A005616(n) + A005738(n) [From Kodandapani and Seth]. - _Sean A. Irvine_, Jul 21 2016
