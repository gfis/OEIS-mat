#!perl

# Extract signatures from %H records
# @(#) $Id$
# 2021-06-01, Georg Fischer
#
#:# Usage:
#:#   grep -E "^%[H]" $(COMMON)/jcat25.txt \
#:#   | perl holfsig.pl > output.tmp
#---------------------------------
use strict;
use integer;
use warnings;

while(<>) {
    s{\s+\Z}{}; # chompr
    my $line = $_;
    my $aseqno = substr($line, 3, 7);
    $line =~ m{\#order\_(\d+)}; 
    my $order = ($1 || -1) + 0;
    if ($line =~ m{signature *\(?([\-\d\, ]+)}) { 
        my $signature = $1;
        $signature =~ s{ }{}g;
        my @recs = (0, reverse(split(/\,/, $signature)), -1);
        my $matrix = "[" . join(",", @recs) . "]";
        print join("\t", $aseqno, "holos", 0, $matrix, $order, 0, 0, "Lin.rec. signature: ($signature)") . "\n"; 
    }
} # while <>
__DATA__
%H A051515 <a href="/index/Rec#order_09">Index entries for linear recurrences with constant coefficients</a>, signature (1,4,-4,-6,6,4,-4,-1,1).
%H A057348 <a href="/index/Rec#order_360">Index entries for linear recurrences with constant coefficients</a>, order 360.
%H A057592 <a href="/index/Rec#order_05">Index entries for linear recurrences with constant coefficients</a>, signature (3,1,-5,-1,1).
%H A060242 <a href="/index/Rec#order_04">Index entries for linear recurrences with constant coefficients</a>, signature (15,-70,120,-64).
