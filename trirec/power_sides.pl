#!perl

# Determine triangles where the LeftSide and RightSide traits are some n^k
# @(#) $Id$
# 2020-04-01, Georg Fischer
#
#:# Usage:
#:#   perl powerd_sides.pl traits2.tmp > $@.tmp
#--------------------------------------------------------
use strict;
use integer;
use warnings;
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);
my $timestamp = sprintf ("%04d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec);
$timestamp = sprintf ("%04d-%02d-%02d", $year + 1900, $mon + 1, $mday);

my $debug = 0;
if (scalar(@ARGV) == 0) {
    print `grep -E "^#:#" $0 | cut -b3-`;
    exit;
}
while (scalar(@ARGV) > 0 and ($ARGV[0] =~ m{\A[\-\+]})) {
    my $opt = shift(@ARGV);
    if (0) {
    } elsif ($opt  =~ m{d}) {
        $debug     = shift(@ARGV);
    } else {
        die "invalid option \"$opt\"\n";
    }
} # while $opt

my $oseqno = "A000000"; # old aseqno
my ($lbase, $rbase); # bases of Left/RightSide powers
while (<>) {
    my $line = $_;
    $line =~ s{\s+\Z}{}; # chompr
    if ($line =~ m{\A(A\d+)}) {
        my ($aseqno, $trait, $termno, $termlist) = split(/\t/, $line);
        if ($termno < 2) {
            # ignore
        } elsif ($trait =~ m{LeftSide}i) {
            $lbase = &get_base($termlist);
        } elsif ($trait =~ m{RightSide}i) {
            $rbase = &get_base($termlist);
            if ($lbase != 0 and $rbase != 0) {
                print join("\t", $aseqno, "$lbase,$rbase") . "\n";
            }
        }
    } else {
        # ignore
    }
} # while <>
#----
sub get_base {
    my ($termlist) = @_;
    my @terms = split(/\, */, $termlist);
    shift(@terms); # should be 1
    my $base = shift(@terms);
    my $old_term = $base;
    my $busy = 1;
    while ($busy == 1 and scalar(@terms) > 0 and length($old_term) < 16) {
        my $new_term = shift(@terms);
        if ($old_term * $base != $new_term) {
            $busy = 0;
        } else {
            $old_term = $new_term;
        }
    } # while busy
    return $busy == 1 ? $base : 0;
} # get_base
#--------------------------------------------
__DATA__
A038215 LeftSide    9   1,2,4,8,16,32,64,128,256
A038215 RightSide   8   1,9,81,729,6561,59049,531441,4782969
A038215 PosHalf 9   1,13,169,2197,28561,371293,4826809,62748517,10534912
A038215 NegHalf 9   1,5,25,125,625,3125,15625,78125,8175616
A038215 N0TS    9   0,9,198,3267,47916,658845,8696754,111608343,299520
A038215 NATS    9   1,20,319,4598,62557,819896,10468315,131095514,454144
A038216 Sequence    38  1,2,10,4,40,100,8,120,600,1000,16,320,2400,8000,10000,32,800,8000,40000,100000,100000,64,1920,24000,160000,600000,1200000,1000000,128,4480,67200,560000,2800000,8400000,14000000,10000000,256,10240
A038216 RowSum  9   1,12,144,1728,20736,248832,2985984,35831808,10496
A038216 EvenSum 9   1,2,104,608,12416,108032,1624064,16867328,256
A038216 OddSum  9   0,10,40,1120,8320,140800,1361920,18964480,10240
A038216 AltSum  9   1,-8,64,-512,4096,-32768,262144,-2097152,-9984
A038216 DiagSum 9   1,2,14,48,236,952,4264,18048,78736
A038216 Central 4   1,40,2400,160000
A038216 LeftSide    9   1,2,4,8,16,32,64,128,256
A038216 RightSide   8   1,10,100,1000,10000,100000,1000000,10000000
