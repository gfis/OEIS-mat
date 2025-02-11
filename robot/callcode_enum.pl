#!perl

# Append a sequential number for all seq4 records with the same A-number
# @(#) $Id$
# 2025-02-11, Georg Fischer: copied from polyx_post.pl
#
#:# Usage:
#:#   perl callcode_enum.pl in.seq4 > out.seq4
#---------------------------------
use strict;
use integer;
use warnings;

my ($aseqno, $callcode, @rest);
my $line;
my $oseqno = "A000000";
my $icc = 0;
my $max_icc = 0;

while(<>) {
    s{\s*\Z}{}; # chompr
    ($aseqno, $callcode, @rest) = split(/\t/);
    if ($aseqno ne $oseqno) {
        $oseqno = $aseqno;
        if ($icc > $max_icc) {
            $max_icc = $icc;
        }
        $icc = 0;
    }
    $icc ++;
    $callcode .= ".$icc";
    print join("\t", $aseqno, $callcode, @rest) . "\n";
} # while <>
print STDERR "# max_icc = $max_icc\n";
