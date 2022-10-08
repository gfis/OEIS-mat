#!perl

# ptrans.pl - grep A-numbers from Peter's paper
# @(#) $Id$
# 2022-09-29, Georg Fischer

use strict;
use warnings;
use integer;

while (<>) {
    s/\s+\Z//; # chompr
    my $line = $_;
    foreach my $aseqno ($line =~ m{(A\d{6})}g) {
        print "$aseqno\n";
    }
}
__DATA__