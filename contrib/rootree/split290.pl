#!perl

# split290.pl - split output of PARI for A055290
# @(#) $Id$
# 2022-03-07, Georg Fischer

use strict;
use integer;
use warnings;

my $colno = shift(@ARGV);
my $dist  = 1;
if (scalar(@ARGV) > 0) {
    $dist = shift(@ARGV);
}
my $offset = $colno + 1 + $dist;
while (<>) {
    s/\s//g;
    s/^A\D+//;
    my @row = (0, split(/\,/, $_));
    if (scalar(@row) - 1 - $dist > $colno) {
        print "$offset $row[$colno]\n";
        $offset ++;
    }
} # while <>
